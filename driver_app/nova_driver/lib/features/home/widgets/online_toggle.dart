import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

/// Yandex Pro uslubidagi katta "Chiqish / To'xtatish" tugmasi.
/// Yoshi kattalar uchun: yirik, aniq yozuv, yuqori kontrast.
class GoOnlineButton extends StatelessWidget {
  final bool isOnline;
  final ValueChanged<bool> onToggle;

  const GoOnlineButton({
    super.key,
    required this.isOnline,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 68,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          onToggle(!isOnline);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isOnline ? Colors.white : NovaColors.amber,
          foregroundColor: NovaColors.textPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          side: isOnline
              ? const BorderSide(color: Color(0xFFE5E7EB), width: 2)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: isOnline ? NovaColors.online : NovaColors.textPrimary,
                shape: BoxShape.circle,
                boxShadow: isOnline
                    ? [
                        BoxShadow(
                          color: NovaColors.online.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isOnline ? 'TO\'XTATISH' : 'CHIQISH (ONLAYN)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Yuqoridagi holat ko'rsatkichi (status chip).
class OnlineStatusChip extends StatelessWidget {
  final bool isOnline;
  final VoidCallback? onTap;

  const OnlineStatusChip({
    super.key,
    required this.isOnline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isOnline ? NovaColors.online : NovaColors.offline,
                  shape: BoxShape.circle,
                  boxShadow: isOnline
                      ? [
                          BoxShadow(
                            color: NovaColors.online.withValues(alpha: 0.55),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isOnline ? 'Onlayn' : 'Oflayn',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isOnline ? NovaColors.onlineDark : NovaColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Eski API mosligi.
class OnlineToggle extends StatelessWidget {
  final bool isOnline;
  final ValueChanged<bool> onToggle;

  const OnlineToggle({
    super.key,
    required this.isOnline,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GoOnlineButton(isOnline: isOnline, onToggle: onToggle);
  }
}
