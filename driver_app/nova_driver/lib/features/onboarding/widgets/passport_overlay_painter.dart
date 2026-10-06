import 'dart:math' as math;
import 'package:flutter/material.dart';

class PassportOverlayPainter extends CustomPainter {
  final Rect cutout;
  final Color overlayColor;
  final double bracketLength;
  final double bracketWidth;
  final double cornerRadius;
  final Color bracketColor;
  final Color guideColor;

  PassportOverlayPainter({
    required this.cutout,
    this.overlayColor = Colors.black54,
    this.bracketLength = 36,
    this.bracketWidth = 4,
    this.cornerRadius = 14,
    this.bracketColor = Colors.white,
    this.guideColor = const Color(0x88FFFFFF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawOverlayMask(canvas, size);
    _drawCornerBrackets(canvas);
    _drawGuideElements(canvas);
  }

  void _drawOverlayMask(Canvas canvas, Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(cutout, Radius.circular(cornerRadius)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, Paint()..color = overlayColor);
  }

  void _drawCornerBrackets(Canvas canvas) {
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

  void _drawGuideElements(Canvas canvas) {
    final midY = cutout.center.dy;
    final pad = cutout.width * 0.08;

    _drawText(canvas, 'Chegaralarga moslang', Offset(cutout.center.dx, cutout.top + 18),
        fontSize: 11, color: const Color(0xAAFFFFFF));

    final dashedPaint = Paint()
      ..color = guideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final dashW = cutout.width * 0.035;
    final gap = cutout.width * 0.02;
    final startX = cutout.left + pad;
    final endX = cutout.right - pad;
    double x = startX;
    while (x < endX) {
      final segEnd = math.min(x + dashW, endX);
      canvas.drawLine(Offset(x, midY), Offset(segEnd, midY), dashedPaint);
      x += dashW + gap;
    }

    final iconLeft = cutout.left + cutout.width * 0.2;
    final iconRight = cutout.right - cutout.width * 0.2;
    final iconAreaTop = midY + 12;
    final iconAreaBottom = cutout.bottom - 36;
    final iconCenterY = (iconAreaTop + iconAreaBottom) / 2;

    _drawPersonSilhouette(canvas, Offset(iconLeft, iconCenterY), iconAreaBottom - iconAreaTop);
    _drawTextLines(canvas, Offset(iconRight - cutout.width * 0.28, iconAreaTop + 8),
        cutout.width * 0.28, iconAreaBottom - iconAreaTop - 16);
    _drawSingleLine(canvas, Offset(cutout.left + pad, cutout.bottom - 24), cutout.width - pad * 2);

    _drawText(canvas, 'Pasport', Offset(cutout.center.dx, cutout.bottom + 22),
        fontSize: 14, color: const Color(0xFF22C55E), fontWeight: FontWeight.w700);
  }

  void _drawText(Canvas canvas, String text, Offset center,
      {double fontSize = 11, Color color = Colors.white, FontWeight fontWeight = FontWeight.w600}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: fontWeight)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  void _drawPersonSilhouette(Canvas canvas, Offset center, double areaHeight) {
    final scale = areaHeight / 90;
    final cx = center.dx;
    final cy = center.dy;

    final headPaint = Paint()
      ..color = guideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final headRadius = 10 * scale;
    final headCenter = Offset(cx, cy - 20 * scale);
    canvas.drawCircle(headCenter, headRadius, headPaint);

    final shoulderPaint = Paint()
      ..color = guideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(cx - 18 * scale, cy + 14 * scale);
    path.quadraticBezierTo(cx - 8 * scale, cy - 6 * scale, cx, cy - 10 * scale);
    path.quadraticBezierTo(cx + 8 * scale, cy - 6 * scale, cx + 18 * scale, cy + 14 * scale);
    canvas.drawPath(path, shoulderPaint);
  }

  void _drawTextLines(Canvas canvas, Offset topLeft, double width, double areaHeight) {
    final paint = Paint()
      ..color = guideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final lineH = areaHeight / 6;
    final startY = topLeft.dy + lineH * 0.5;

    canvas.drawLine(
      Offset(topLeft.dx, startY),
      Offset(topLeft.dx + width, startY),
      paint,
    );
    canvas.drawLine(
      Offset(topLeft.dx, startY + lineH * 1.5),
      Offset(topLeft.dx + width * 0.8, startY + lineH * 1.5),
      paint,
    );
    canvas.drawLine(
      Offset(topLeft.dx, startY + lineH * 3),
      Offset(topLeft.dx + width * 0.65, startY + lineH * 3),
      paint,
    );
  }

  void _drawSingleLine(Canvas canvas, Offset topLeft, double width) {
    final paint = Paint()
      ..color = guideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(topLeft.dx, topLeft.dy),
      Offset(topLeft.dx + width, topLeft.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
