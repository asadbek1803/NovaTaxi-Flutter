import 'package:flutter/material.dart';

class SelfieOverlayPainter extends CustomPainter {
  final double centerX;
  final double centerY;
  final double radiusX;
  final double radiusY;
  final Color overlayColor;
  final Color borderColor;
  final double borderWidth;
  final bool isAligned;

  SelfieOverlayPainter({
    required this.centerX,
    required this.centerY,
    required this.radiusX,
    required this.radiusY,
    this.overlayColor = Colors.black54,
    this.borderColor = Colors.white,
    this.borderWidth = 2.5,
    this.isAligned = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: radiusX * 2,
        height: radiusY * 2,
      ))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, Paint()..color = overlayColor);

    final borderPaint = Paint()
      ..color = isAligned ? const Color(0xFF22C55E) : borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: radiusX * 2,
        height: radiusY * 2,
      ),
      borderPaint,
    );

    if (isAligned) {
      final glowPaint = Paint()
        ..color = const Color(0xFF22C55E).withValues(alpha: 0.12)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: radiusX * 2 + 20,
          height: radiusY * 2 + 20,
        ),
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SelfieOverlayPainter old) =>
      old.isAligned != isAligned;
}
