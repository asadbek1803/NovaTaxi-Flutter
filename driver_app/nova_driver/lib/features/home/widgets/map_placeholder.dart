import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Yandex uslubidagi soddalashtirilgan xarita foni.
class MapPlaceholder extends StatelessWidget {
  final bool isOnline;

  const MapPlaceholder({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isOnline
              ? const [
                  Color(0xFFE8F0DC),
                  Color(0xFFDCE8C8),
                  Color(0xFFD0E0B8),
                ]
              : const [
                  Color(0xFF3A3A3C),
                  Color(0xFF2C2C2E),
                  Color(0xFF1C1C1E),
                ],
        ),
      ),
      child: CustomPaint(
        painter: _MapGridPainter(isOnline: isOnline),
        child: Stack(
          children: [
            // Soft vignette
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.1,
                    colors: [
                      Colors.transparent,
                      (isOnline ? Colors.black : Colors.black)
                          .withValues(alpha: isOnline ? 0.04 : 0.25),
                    ],
                  ),
                ),
              ),
            ),

            // Road labels
            Positioned(
              top: MediaQuery.paddingOf(context).top + 100,
              left: 20,
              child: _RoadLabel(text: 'A. Temur ko\'chasi', isOnline: isOnline),
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 180,
              right: 24,
              child: _RoadLabel(text: 'Buyuk Ipak Yo\'li', isOnline: isOnline),
            ),
            Positioned(
              bottom: 280,
              left: 48,
              child: _RoadLabel(text: 'Navoiy ko\'chasi', isOnline: isOnline),
            ),

            // Driver location pin
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isOnline)
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: NovaColors.amber.withValues(alpha: 0.18),
                            ),
                          ),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: isOnline ? NovaColors.amber : Colors.grey.shade600,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isOnline ? NovaColors.amber : Colors.black)
                                    .withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Icon(
                            Icons.local_taxi_rounded,
                            size: 30,
                            color: isOnline ? NovaColors.textPrimary : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isOnline
                          ? Colors.white
                          : Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      isOnline ? 'Siz shu yerdasiz' : 'Oflayn rejim',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isOnline
                            ? NovaColors.textPrimary
                            : Colors.white.withValues(alpha: 0.9),
                      ),
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

class _RoadLabel extends StatelessWidget {
  final String text;
  final bool isOnline;

  const _RoadLabel({required this.text, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isOnline
            ? Colors.white.withValues(alpha: 0.82)
            : Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isOnline ? const Color(0xFF4B5563) : Colors.white54,
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  final bool isOnline;

  _MapGridPainter({required this.isOnline});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isOnline ? const Color(0xFF9BB87A) : const Color(0xFF555555))
          .withValues(alpha: 0.12)
      ..strokeWidth = 1;

    const spacing = 48.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final roadPaint = Paint()
      ..color = (isOnline ? const Color(0xFFB8C99A) : const Color(0xFF666666))
          .withValues(alpha: 0.35)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height * 0.35),
      Offset(size.width, size.height * 0.42),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.22, 0),
      Offset(size.width * 0.28, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.68, 0),
      Offset(size.width * 0.58, size.height),
      roadPaint,
    );

    // Side streets
    final sidePaint = Paint()
      ..color = roadPaint.color.withValues(alpha: 0.2)
      ..strokeWidth = 5;

    canvas.drawLine(
      Offset(0, size.height * 0.6),
      Offset(size.width, size.height * 0.55),
      sidePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.45, 0),
      Offset(size.width * 0.5, size.height),
      sidePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) =>
      oldDelegate.isOnline != isOnline;
}
