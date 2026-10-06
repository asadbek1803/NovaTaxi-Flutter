import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NovaColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Hujjatlar',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NovaColors.online.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: NovaColors.online.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: NovaColors.online, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Barcha hujjatlar tasdiqlangan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: NovaColors.onlineDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Shaxsiy hujjatlar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: NovaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _DocumentCard(
              icon: Icons.badge_rounded,
              title: 'Pasport',
              subtitle: 'AB 1234567',
              expiryDate: '12.12.2030',
              status: _DocStatus.verified,
            ),
            _DocumentCard(
              icon: Icons.description_rounded,
              title: 'Haydovchilik guvohnomasi',
              subtitle: 'B kategoriya · № 789456',
              expiryDate: '15.06.2028',
              status: _DocStatus.verified,
            ),
            const SizedBox(height: 24),
            const Text(
              'Transport hujjatlari',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: NovaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _DocumentCard(
              icon: Icons.shield_rounded,
              title: 'Majburiy sug\'urta (OSAGO)',
              subtitle: 'Polis № 123456789',
              expiryDate: '01.03.2027',
              status: _DocStatus.verified,
            ),
            _DocumentCard(
              icon: Icons.verified_rounded,
              title: 'Texnik ko\'rik',
              expiryDate: '20.11.2026',
              status: _DocStatus.expiringSoon,
            ),
            _DocumentCard(
              icon: Icons.description_outlined,
              title: 'Transport egasi guvohnomasi',
              subtitle: 'Cobalt · 01 A 123 BC',
              status: _DocStatus.verified,
            ),
            const SizedBox(height: 24),
            const Text(
              'Rasmlar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: NovaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _DocumentCard(
              icon: Icons.photo_camera_rounded,
              title: 'Selfie (Yuz rasmi)',
              status: _DocStatus.verified,
            ),
            _DocumentCard(
              icon: Icons.directions_car_rounded,
              title: 'Transport rasmi',
              subtitle: 'Old tomondan',
              status: _DocStatus.verified,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.cloud_upload_rounded, size: 22),
                label: const Text(
                  'Yangi hujjat yuklash',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: NovaColors.textPrimary,
                  side: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _DocStatus { verified, pending, expired, expiringSoon }

class _DocumentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? expiryDate;
  final _DocStatus status;

  const _DocumentCard({
    required this.icon,
    required this.title,
    this.subtitle,
    this.expiryDate,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 26, color: _statusColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: NovaColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: NovaColors.textSecondary,
                    ),
                  ),
                ],
                if (expiryDate != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Muddat: $expiryDate',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: status == _DocStatus.expiringSoon
                          ? Colors.orange
                          : NovaColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _StatusBadge(status: status),
        ],
      ),
    );
  }

  Color get _statusColor {
    switch (status) {
      case _DocStatus.verified:
        return NovaColors.online;
      case _DocStatus.pending:
        return NovaColors.amberDeep;
      case _DocStatus.expired:
        return NovaColors.danger;
      case _DocStatus.expiringSoon:
        return Colors.orange;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final _DocStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bgColor;
    Color textColor;

    switch (status) {
      case _DocStatus.verified:
        label = 'Tasdiqlangan';
        bgColor = NovaColors.online.withValues(alpha: 0.12);
        textColor = NovaColors.onlineDark;
        break;
      case _DocStatus.pending:
        label = 'Kutilmoqda';
        bgColor = NovaColors.amberLight;
        textColor = NovaColors.amberDeep;
        break;
      case _DocStatus.expired:
        label = 'Muddati o\'tgan';
        bgColor = NovaColors.danger.withValues(alpha: 0.1);
        textColor = NovaColors.danger;
        break;
      case _DocStatus.expiringSoon:
        label = 'Tugayapti';
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
