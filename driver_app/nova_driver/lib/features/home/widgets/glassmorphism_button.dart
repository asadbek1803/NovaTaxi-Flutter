import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class GlassButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final double? size;
  final bool isActive;

  const GlassButton({
    super.key,
    required this.onTap,
    required this.child,
    this.size,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: size ?? 56,
            height: size ?? 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.25),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class GlassActionChip extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final String label;
  final bool isActive;

  const GlassActionChip({
    super.key,
    this.onTap,
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isActive
        ? NovaColors.online.withValues(alpha: 0.2)
        : Colors.white.withValues(alpha: 0.25);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumGoOnlineButton extends StatefulWidget {
  final bool isOnline;
  final ValueChanged<bool> onToggle;

  const PremiumGoOnlineButton({
    super.key,
    required this.isOnline,
    required this.onToggle,
  });

  @override
  State<PremiumGoOnlineButton> createState() => _PremiumGoOnlineButtonState();
}

class _PremiumGoOnlineButtonState extends State<PremiumGoOnlineButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = widget.isOnline;

    return GestureDetector(
      onTapDown: (_) => _animController.forward(),
      onTapUp: (_) {
        _animController.reverse();
        HapticFeedback.heavyImpact();
        widget.onToggle(!isOnline);
      },
      onTapCancel: () => _animController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: double.infinity,
          height: 68,
          decoration: BoxDecoration(
            color: isOnline ? Colors.white : NovaColors.amber,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              if (!isOnline)
                BoxShadow(
                  color: NovaColors.amber.withValues(alpha: 0.45),
                  blurRadius: 28,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isOnline ? NovaColors.online : NovaColors.textPrimary,
                  shape: BoxShape.circle,
                  boxShadow: isOnline
                      ? [
                          BoxShadow(
                            color: NovaColors.online.withValues(alpha: 0.6),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                isOnline ? 'TO\'XTATISH' : 'CHIQISH (ONLAYN)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: isOnline
                      ? NovaColors.textPrimary
                      : NovaColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
