import 'dart:math';
import 'package:flutter/material.dart';

class RouteMapPainter extends CustomPainter {
  final double progress;

  RouteMapPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.2)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final driverPos = Offset(size.width * 0.2, size.height * 0.78);
    final customerPos = Offset(size.width * 0.78, size.height * 0.22);

    final controlPoint1 = Offset(size.width * 0.15, size.height * 0.35);
    final controlPoint2 = Offset(size.width * 0.75, size.height * 0.60);

    final path = Path()
      ..moveTo(driverPos.dx, driverPos.dy)
      ..cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        customerPos.dx, customerPos.dy,
      );

    final totalLength = _estimatePathLength(driverPos, controlPoint1, controlPoint2, customerPos);
    final visibleLength = totalLength * progress.clamp(0.0, 1.0);

    canvas.drawPath(path, shadowPaint);

    final metrics = path.computeMetrics().first;
    final extractedPath = metrics.extractPath(0, visibleLength);
    canvas.drawPath(extractedPath, routePaint);

    _drawDirectionArrows(canvas, path, progress, size);
  }

  void _drawDirectionArrows(Canvas canvas, Path path, double progress, Size size) {
    if (progress < 0.1) return;

    final metrics = path.computeMetrics().first;
    final totalLength = metrics.length;

    final arrowPositions = [0.25, 0.5, 0.75];
    final arrowPaint = Paint()
      ..color = const Color(0xFF92400E)
      ..style = PaintingStyle.fill;

    for (final pos in arrowPositions) {
      if (pos > progress) continue;

      final distance = totalLength * pos;
      final tangent = metrics.getTangentForOffset(distance);
      if (tangent == null) continue;

      final center = tangent.position;
      final angle = tangent.angle;

      final arrowSize = 8.0;
      final path2 = Path()
        ..moveTo(
          center.dx + cos(angle) * arrowSize,
          center.dy + sin(angle) * arrowSize,
        )
        ..lineTo(
          center.dx + cos(angle + 2.5) * arrowSize * 0.6,
          center.dy + sin(angle + 2.5) * arrowSize * 0.6,
        )
        ..lineTo(
          center.dx + cos(angle - 2.5) * arrowSize * 0.6,
          center.dy + sin(angle - 2.5) * arrowSize * 0.6,
        )
        ..close();

      canvas.drawPath(path2, arrowPaint);
    }
  }

  double _estimatePathLength(Offset p0, Offset p1, Offset p2, Offset p3) {
    double length = 0;
    Offset prev = p0;
    for (double t = 0.1; t <= 1.0; t += 0.05) {
      final point = _cubicBezier(p0, p1, p2, p3, t);
      length += (point - prev).distance;
      prev = point;
    }
    return length;
  }

  Offset _cubicBezier(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final u = 1 - t;
    return p0 * (u * u * u) +
        p1 * (3 * u * u * t) +
        p2 * (3 * u * t * t) +
        p3 * (t * t * t);
  }

  @override
  bool shouldRepaint(covariant RouteMapPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
