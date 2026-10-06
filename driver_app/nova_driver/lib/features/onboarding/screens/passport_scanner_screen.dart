import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../models/onboarding_data.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/passport_overlay_painter.dart';
import '../widgets/camera_control_bars.dart';

class PassportScannerScreen extends StatefulWidget {
  const PassportScannerScreen({super.key});

  @override
  State<PassportScannerScreen> createState() => _PassportScannerScreenState();
}

class _PassportScannerScreenState extends State<PassportScannerScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _isProcessing = false;
  bool _flashOn = false;
  String? _capturedImagePath;
  String? _initError;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
      _initError = null;
      _isInitialized = false;
    });

    await _controller?.dispose();
    _controller = null;

    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _initError = 'Kameradan foydalanish uchun ruxsat kerak';
        });
      }
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          setState(() {
            _isInitializing = false;
            _initError = 'Kamera topilmadi';
          });
        }
        return;
      }

      final controller = CameraController(
        _cameras!.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      _controller = controller;

      await controller.initialize();
      if (!mounted) return;

      setState(() {
        _isInitialized = true;
        _isInitializing = false;
      });
    } catch (e) {
      await _controller?.dispose();
      _controller = null;
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _isInitializing = false;
          _initError = 'Kamerani ishga tushirishda xato';
        });
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_isInitialized || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final image = await _controller!.takePicture();

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newPath = path.join(directory.path, 'passport_$timestamp.jpg');

      await File(image.path).copy(newPath);

      if (mounted) {
        setState(() {
          _capturedImagePath = newPath;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rasmni saqlashda xato: $e')),
        );
      }
    }
  }

  Future<void> _importFromGallery() async {
    try {
      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newPath = path.join(directory.path, 'passport_$timestamp.jpg');

      await File(picked.path).copy(newPath);

      if (mounted) {
        setState(() {
          _capturedImagePath = newPath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rasmni import qilishda xato: $e')),
        );
      }
    }
  }

  void _retakePhoto() {
    setState(() => _capturedImagePath = null);
  }

  void _confirmPhoto() {
    if (_capturedImagePath == null) return;

    final documentUpload = DocumentUpload(
      type: AppConstants.docPassport,
      filePath: _capturedImagePath!,
      fileName: path.basename(_capturedImagePath!),
    );

    context.read<OnboardingProvider>().updatePassportPhoto(documentUpload);
    context.read<OnboardingProvider>().nextStep();
  }

  void _toggleFlash() async {
    if (_controller == null) return;
    _flashOn = !_flashOn;
    await _controller!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _capturedImagePath != null
          ? _buildPreviewView()
          : _buildCameraView(),
    );
  }

  Widget _buildCameraView() {
    if (_initError != null) {
      return _buildErrorView();
    }

    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: NovaColors.amber),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_controller!),
        _buildPassportOverlay(),
        CameraTopBar(onFlash: _toggleFlash, flashOn: _flashOn),
        _buildLabelBelow(),
        CameraBottomBar(
          onBack: () => context.read<OnboardingProvider>().previousStep(),
          onCapture: _capturePhoto,
          onGallery: _importFromGallery,
          isProcessing: _isProcessing,
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 64),
            const SizedBox(height: 24),
            Text(
              _initError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeCamera,
              style: ElevatedButton.styleFrom(backgroundColor: NovaColors.amber),
              child: const Text('Qayta urinish'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _importFromGallery,
              child: const Text(
                'Galereyadan tanlash',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassportOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cutoutW = w * 0.82;
        final cutoutH = cutoutW * 1.414;
        final left = (w - cutoutW) / 2;
        final top = (constraints.maxHeight - cutoutH) / 2 - 20;

        final cutout = Rect.fromLTWH(left, top, cutoutW, cutoutH);

        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: PassportOverlayPainter(cutout: cutout),
        );
      },
    );
  }

  Widget _buildLabelBelow() {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 60,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Pasportni ramka ichiga to\'g\'ri joylashtiring',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(File(_capturedImagePath!), fit: BoxFit.contain),
        _buildPreviewActions(),
      ],
    );
  }

  Widget _buildPreviewActions() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _retakePhoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Qayta olish', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _confirmPhoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: NovaColors.amber,
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Tasdiqlash', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
