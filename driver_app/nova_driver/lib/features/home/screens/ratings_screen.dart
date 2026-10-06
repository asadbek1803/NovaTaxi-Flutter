import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class RatingsScreen extends StatelessWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NovaColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reyting',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: NovaColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Mijozlar baholari',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: NovaColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),

              // Big rating card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      '4.8',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: NovaColors.textPrimary,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                          color: NovaColors.amber,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '245 ta baholash asosida',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: NovaColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Stats grid
              Row(
                children: [
                  _StatCard(icon: Icons.local_taxi_rounded, value: '1 245', label: 'Buyurtmalar'),
                  const SizedBox(width: 12),
                  _StatCard(icon: Icons.cancel_outlined, value: '2.1%', label: 'Bekor qilish'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatCard(icon: Icons.thumb_up_rounded, value: '97%', label: 'Ijobiy baho'),
                  const SizedBox(width: 12),
                  _StatCard(icon: Icons.access_time_rounded, value: '99%', label: 'Vaqtida'),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'So\'nggi baholar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: NovaColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _ReviewTile(
                name: 'Sardor K.',
                rating: 5,
                comment: 'Juda yaxshi haydovchi! Tez va qulay.',
              ),
              _ReviewTile(
                name: 'Nodira M.',
                rating: 5,
                comment: 'Mashina toza va yo\'nalish to\'g\'ri edi.',
              ),
              _ReviewTile(
                name: 'Bobur T.',
                rating: 4,
                comment: 'Yaxshi xizmat, lekin biroz kechikdi.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: NovaColors.amberDeep),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: NovaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: NovaColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final String name;
  final int rating;
  final String comment;

  const _ReviewTile({
    required this.name,
    required this.rating,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: NovaColors.amber.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name[0],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: NovaColors.amberDeep,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Row(
                children: List.generate(
                  rating,
                  (i) => const Icon(Icons.star_rounded, color: NovaColors.amber, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 15,
              color: NovaColors.textSecondary,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
