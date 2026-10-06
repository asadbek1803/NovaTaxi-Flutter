import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../models/onboarding_data.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/selfie_overlay_painter.dart';
import '../widgets/camera_control_bars.dart';

class SelfieCaptureScreen extends StatefulWidget {
  const SelfieCaptureScreen({super.key});

  @override
  State<SelfieCaptureScreen> createState() => _SelfieCaptureScreenState();
}

class _SelfieCaptureScreenState extends State<SelfieCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _isProcessing = false;
  bool _flashOn = false;
  String? _capturedImagePath;
  String? _initError;

  FaceDetector? _faceDetector;
  bool _isFaceDetected = false;
  bool _isFaceCentered = false;
  int _stableFrames = 0;
  static const int _requiredStableFrames = 30;
  bool _autoCaptureEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeFaceDetection();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  void _initializeFaceDetection() {
    final options = FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      enableLandmarks: true,
      minFaceSize: 0.15,
      performanceMode: FaceDetectorMode.accurate,
    );
    _faceDetector = FaceDetector(options: options);
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

      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      final controller = CameraController(
        frontCamera,
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
      await _startFaceDetectionStream();
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

  Future<void> _startFaceDetectionStream() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isStreamingImages) return;

    try {
      await controller.startImageStream(_detectFaces);
      if (mounted) setState(() => _autoCaptureEnabled = true);
    } catch (e) {
      debugPrint('Face detection stream error: $e');
      if (mounted) setState(() => _autoCaptureEnabled = false);
    }
  }

  Future<void> _detectFaces(CameraImage image) async {
    if (_faceDetector == null || _isProcessing) return;

    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector!.processImage(inputImage);

      if (mounted) {
        setState(() {
          _isFaceDetected = faces.isNotEmpty;
          _isFaceCentered = faces.isNotEmpty && _isFaceCenteredCheck(faces.first);
        });

        if (_isFaceCentered && !_isProcessing) {
          _stableFrames++;
          if (_stableFrames >= _requiredStableFrames) {
            _capturePhoto();
          }
        } else {
          _stableFrames = 0;
        }
      }
    } catch (e) {
      debugPrint('Face detection error: $e');
    }
  }

  bool _isFaceCenteredCheck(Face face) {
    final centerX = face.boundingBox.left + face.boundingBox.width / 2;
    final centerY = face.boundingBox.top + face.boundingBox.height / 2;

    final imageWidth = _controller?.value.previewSize?.height ?? 1;
    final imageHeight = _controller?.value.previewSize?.width ?? 1;

    final centerTolerance = 0.15;
    final isCenterX = (centerX / imageWidth).abs() < centerTolerance;
    final isCenterY = (centerY / imageHeight).abs() < centerTolerance;
    final isLargeEnough = face.boundingBox.width > imageWidth * 0.3;

    return isCenterX && isCenterY && isLargeEnough;
  }

  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final plane = image.planes.first;
      final rotation = InputImageRotationValue.fromRawValue(_controller!.description.sensorOrientation) ?? InputImageRotation.rotation0deg;

      InputImageFormat format;
      switch (image.format.group) {
        case ImageFormatGroup.yuv420:
          format = InputImageFormat.yuv420;
          break;
        case ImageFormatGroup.nv21:
          format = InputImageFormat.nv21;
          break;
        case ImageFormatGroup.bgra8888:
          format = InputImageFormat.bgra8888;
          break;
        default:
          format = InputImageFormat.nv21;
      }

      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      );

      return InputImage.fromBytes(bytes: plane.bytes, metadata: metadata);
    } catch (e) {
      debugPrint('Image conversion error: $e');
      return null;
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_isInitialized || _isProcessing) return;

    setState(() => _isProcessing = true);
    _controller?.stopImageStream();

    try {
      final image = await _controller!.takePicture();

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newPath = path.join(directory.path, 'selfie_$timestamp.jpg');

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

  void _retakePhoto() {
    setState(() {
      _capturedImagePath = null;
      _isProcessing = false;
      _stableFrames = 0;
    });
    _startFaceDetectionStream();
  }

  void _confirmPhoto() {
    if (_capturedImagePath == null) return;

    final documentUpload = DocumentUpload(
      type: AppConstants.docSelfie,
      filePath: _capturedImagePath!,
      fileName: path.basename(_capturedImagePath!),
    );

    context.read<OnboardingProvider>().updateSelfiePhoto(documentUpload);
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
        _buildOvalOverlay(),
        CameraTopBar(onFlash: _toggleFlash, flashOn: _flashOn),
        _buildStatusIndicator(),
        _buildInstructions(),
        CameraBottomBar(
          onBack: () => context.read<OnboardingProvider>().previousStep(),
          onCapture: _capturePhoto,
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
            const Icon(Icons.face_retouching_natural, color: Colors.white54, size: 64),
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
          ],
        ),
      ),
    );
  }

  Widget _buildOvalOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cx = constraints.maxWidth / 2;
        final cy = constraints.maxHeight * 0.4;
        final rx = constraints.maxWidth * 0.32;
        final ry = constraints.maxHeight * 0.22;

        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: SelfieOverlayPainter(
            centerX: cx,
            centerY: cy,
            radiusX: rx,
            radiusY: ry,
            isAligned: _isFaceCentered,
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator() {
    if (!_autoCaptureEnabled) {
      return Positioned(
        bottom: 160,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Pastdagi tugmani bosib suratga oling',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Positioned(
      bottom: 160,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isFaceDetected
                      ? (_isFaceCentered ? Icons.check_circle : Icons.face)
                      : Icons.person_search,
                  color: _isFaceCentered
                      ? NovaColors.online
                      : NovaColors.amber,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  _isFaceCentered
                      ? 'Yuz aniqlandi — Avto suratga olinmoqda...'
                      : (_isFaceDetected
                          ? 'Yuzni markazga joylashtiring'
                          : 'Yuzni kameraga qarating'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (_isFaceCentered && _stableFrames < _requiredStableFrames)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: _stableFrames / _requiredStableFrames,
                  backgroundColor: Colors.grey,
                  valueColor: const AlwaysStoppedAnimation<Color>(NovaColors.online),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
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
          'Yuzni doira ichiga markazda turib qo\'ying\nSurat avto olinadi',
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
                  backgroundColor: NovaColors.online,
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
