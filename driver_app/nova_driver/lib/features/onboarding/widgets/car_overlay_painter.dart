import 'package:flutter/material.dart';

class CarOverlayPainter extends CustomPainter {
  final Rect cutout;
  final Color overlayColor;
  final double bracketLength;
  final double bracketWidth;
  final double cornerRadius;
  final Color bracketColor;

  CarOverlayPainter({
    required this.cutout,
    this.overlayColor = Colors.black54,
    this.bracketLength = 32,
    this.bracketWidth = 4,
    this.cornerRadius = 16,
    this.bracketColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(cutout, Radius.circular(cornerRadius)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, Paint()..color = overlayColor);

    final bp = Paint()
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

    canvas.drawLine(Offset(tl.dx + r, tl.dy), Offset(tl.dx + l, tl.dy), bp);
    canvas.drawLine(Offset(tl.dx, tl.dy + r), Offset(tl.dx, tl.dy + l), bp);

    canvas.drawLine(Offset(tr.dx - l, tr.dy), Offset(tr.dx - r, tr.dy), bp);
    canvas.drawLine(Offset(tr.dx, tr.dy + r), Offset(tr.dx, tr.dy + l), bp);

    canvas.drawLine(Offset(br.dx, br.dy - l), Offset(br.dx, br.dy - r), bp);
    canvas.drawLine(Offset(br.dx - l, br.dy), Offset(br.dx - r, br.dy), bp);

    canvas.drawLine(Offset(bl.dx, bl.dy - l), Offset(bl.dx, bl.dy - r), bp);
    canvas.drawLine(Offset(bl.dx + l, bl.dy), Offset(bl.dx + r, bl.dy), bp);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
