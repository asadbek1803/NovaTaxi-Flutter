import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/order_model.dart';
import '../../../core/theme/app_theme.dart';

/// Yandex Pro uslubidagi katta buyurtma kartasi.
/// Yoshi kattalar uchun: katta shrift, aniq manzillar, yirik tugma.
class IncomingOrderCard extends StatefulWidget {
  final Order order;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final int secondsLeft;

  const IncomingOrderCard({
    super.key,
    required this.order,
    required this.onAccept,
    required this.onDecline,
    this.secondsLeft = 30,
  });

  @override
  State<IncomingOrderCard> createState() => _IncomingOrderCardState();
}

class _IncomingOrderCardState extends State<IncomingOrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: price + timer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              decoration: const BoxDecoration(
                color: NovaColors.amber,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Yangi buyurtma',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5C4A00),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.order.formattedPrice,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: NovaColors.textPrimary,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 20, color: NovaColors.textPrimary),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.secondsLeft} s',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: NovaColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                children: [
                  // Distance / time chips
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.route_rounded,
                        label: widget.order.distance,
                      ),
                      const SizedBox(width: 10),
                      _InfoChip(
                        icon: Icons.schedule_rounded,
                        label: widget.order.estimatedTime,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Addresses
                  _AddressRow(
                    color: NovaColors.online,
                    label: 'Olish joyi',
                    address: widget.order.pickupAddress,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 2,
                        height: 18,
                        color: const Color(0xFFE5E7EB),
                      ),
                    ),
                  ),
                  _AddressRow(
                    color: NovaColors.amberDeep,
                    label: 'Boradigan joy',
                    address: widget.order.destinationAddress,
                  ),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
              child: Row(
                children: [
                  // Decline
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: Material(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onDecline();
                        },
                        child: const Icon(
                          Icons.close_rounded,
                          size: 30,
                          color: NovaColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Accept — large and clear
                  Expanded(
                    child: SizedBox(
                      height: 64,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          widget.onAccept();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NovaColors.online,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 26),
                            SizedBox(width: 10),
                            Text(
                              'QABUL QILISH',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: NovaColors.textSecondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: NovaColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  final Color color;
  final String label;
  final String address;

  const _AddressRow({
    required this.color,
    required this.label,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: NovaColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: NovaColors.textPrimary,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Eski API bilan moslik uchun (agar boshqa joyda ishlatilsa).
class OrderAcceptButton extends StatelessWidget {
  final Order order;
  final VoidCallback onPressed;

  const OrderAcceptButton({
    super.key,
    required this.order,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IncomingOrderCard(
      order: order,
      onAccept: onPressed,
      onDecline: () {},
    );
  }
}
