import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PulsingCarMarker extends StatefulWidget {
  final bool isOnline;

  const PulsingCarMarker({super.key, this.isOnline = true});

  @override
  State<PulsingCarMarker> createState() => _PulsingCarMarkerState();
}

class _PulsingCarMarkerState extends State<PulsingCarMarker>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, _) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isOnline
                        ? NovaColors.amber.withValues(alpha: 0.12)
                        : Colors.grey.withValues(alpha: 0.12),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, _) {
              final opacity = (1.0 - _pulseAnimation.value / 1.6) * 0.3;
              return Transform.scale(
                scale: _pulseAnimation.value * 0.8,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isOnline
                        ? NovaColors.amber.withValues(alpha: opacity)
                        : Colors.grey.withValues(alpha: opacity),
                  ),
                ),
              );
            },
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: widget.isOnline ? NovaColors.amber : Colors.grey.shade500,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: (widget.isOnline ? NovaColors.amber : Colors.black54)
                      .withValues(alpha: 0.5),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_taxi_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
