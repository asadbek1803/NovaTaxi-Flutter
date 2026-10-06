import 'package:flutter/material.dart';

class CameraTopBar extends StatelessWidget {
  final VoidCallback? onClose;
  final VoidCallback? onFlash;
  final bool flashOn;

  const CameraTopBar({
    super.key,
    this.onClose,
    this.onFlash,
    this.flashOn = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top,
          left: 8,
          right: 8,
        ),
        child: Row(
          children: [
            _CircleIconButton(
              icon: Icons.close_rounded,
              onTap: onClose ?? () => Navigator.maybePop(context),
            ),
            const Spacer(),
            _CircleIconButton(
              icon: flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              onTap: onFlash,
              active: flashOn,
            ),
            const SizedBox(width: 8),
            _CircleIconButton(
              icon: Icons.high_quality_rounded,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class CameraBottomBar extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onCapture;
  final VoidCallback? onGallery;
  final bool isProcessing;

  const CameraBottomBar({
    super.key,
    this.onBack,
    this.onCapture,
    this.onGallery,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + 16,
          top: 24,
          left: 32,
          right: 32,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.85),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _CircleIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBack ?? () => Navigator.maybePop(context),
              size: 44,
            ),
            GestureDetector(
              onTap: isProcessing ? null : onCapture,
              child: _CaptureButton(isProcessing: isProcessing),
            ),
            GestureDetector(
              onTap: onGallery,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Import',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final bool active;

  const _CircleIconButton({
    required this.icon,
    this.onTap,
    this.size = 44,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: active
              ? Colors.amber.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: active ? Colors.amber : Colors.white.withValues(alpha: 0.9),
          size: size * 0.5,
        ),
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final bool isProcessing;

  const _CaptureButton({this.isProcessing = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: Center(
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isProcessing ? Colors.grey : Colors.white,
          ),
          child: isProcessing
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
