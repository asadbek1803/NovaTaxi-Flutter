import 'package:flutter/material.dart';

class IdCardOverlayPainter extends CustomPainter {
  final Rect cutout;
  final Color overlayColor;
  final double bracketLength;
  final double bracketWidth;
  final double cornerRadius;
  final Color bracketColor;

  IdCardOverlayPainter({
    required this.cutout,
    this.overlayColor = Colors.black54,
    this.bracketLength = 28,
    this.bracketWidth = 3.5,
    this.cornerRadius = 12,
    this.bracketColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(cutout, Radius.circular(cornerRadius)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, Paint()..color = overlayColor);

    final bracketPaint = Paint()
      ..color = bracketColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = bracketWidth
      ..strokeCap = StrokeCap.round;

    final l = bracketLength;
    final r = cornerRadius.toDouble();
    final tl = cutout.topLeft;
    final tr = cutout.topRight;
    final br = cutout.bottomRight;
    final bl = cutout.bottomLeft;

    canvas.drawLine(Offset(tl.dx + r, tl.dy), Offset(tl.dx + l, tl.dy), bracketPaint);
    canvas.drawLine(Offset(tl.dx, tl.dy + r), Offset(tl.dx, tl.dy + l), bracketPaint);

    canvas.drawLine(Offset(tr.dx - l, tr.dy), Offset(tr.dx - r, tr.dy), bracketPaint);
    canvas.drawLine(Offset(tr.dx, tr.dy + r), Offset(tr.dx, tr.dy + l), bracketPaint);

    canvas.drawLine(Offset(br.dx, br.dy - l), Offset(br.dx, br.dy - r), bracketPaint);
    canvas.drawLine(Offset(br.dx - l, br.dy), Offset(br.dx - r, br.dy), bracketPaint);

    canvas.drawLine(Offset(bl.dx, bl.dy - l), Offset(bl.dx, bl.dy - r), bracketPaint);
    canvas.drawLine(Offset(bl.dx + l, bl.dy), Offset(bl.dx + r, bl.dy), bracketPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
