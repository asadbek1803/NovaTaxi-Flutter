import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import 'profile/transport_screen.dart';
import 'profile/documents_screen.dart';
import 'profile/payment_screen.dart';
import 'profile/settings_screen.dart';
import 'profile/help_screen.dart';
import 'profile/about_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final driver = auth.driver;

    final name = driver?.fullName ?? 'Haydovchi';
    final phone = driver?.phoneNumber ?? '+998 XX XXX XX XX';
    final isVerified = driver?.status == 'approved' || driver?.status == 'active';

    return Scaffold(
      backgroundColor: NovaColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profil',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: NovaColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Shaxsiy ma\'lumotlar va sozlamalar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: NovaColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: NovaColors.amber.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: NovaColors.amber, width: 3),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 52,
                        color: NovaColors.amberDeep,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: NovaColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPhone(phone),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: NovaColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: NovaColors.online.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded, size: 18, color: NovaColors.onlineDark),
                            SizedBox(width: 6),
                            Text(
                              'Tasdiqlangan haydovchi',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: NovaColors.onlineDark,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: NovaColors.amberLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule_rounded, size: 18, color: NovaColors.amberDeep),
                            SizedBox(width: 6),
                            Text(
                              'Tekshiruv kutilmoqda',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: NovaColors.amberDeep,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _MenuTile(
                icon: Icons.directions_car_rounded,
                title: 'Transport',
                subtitle: 'Cobalt, 2020 · 01 A 123 BC',
                onTap: () => _navigateTo(context, const TransportScreen()),
              ),
              _MenuTile(
                icon: Icons.description_rounded,
                title: 'Hujjatlar',
                subtitle: 'Litsenziya, sug\'urta',
                onTap: () => _navigateTo(context, const DocumentsScreen()),
              ),
              _MenuTile(
                icon: Icons.payment_rounded,
                title: 'To\'lov',
                subtitle: 'Karta: **** 4567',
                onTap: () => _navigateTo(context, const PaymentScreen()),
              ),
              _MenuTile(
                icon: Icons.settings_rounded,
                title: 'Sozlamalar',
                subtitle: 'Til, bildirishnomalar',
                onTap: () => _navigateTo(context, const SettingsScreen()),
              ),
              _MenuTile(
                icon: Icons.help_outline_rounded,
                title: 'Yordam',
                subtitle: 'Qo\'llab-quvvatlash markazi',
                onTap: () => _navigateTo(context, const HelpScreen()),
              ),
              _MenuTile(
                icon: Icons.info_outline_rounded,
                title: 'Ilova haqida',
                subtitle: 'Nova Haydovchi · 1.0.0',
                onTap: () => _navigateTo(context, const AboutScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  String _formatPhone(String phone) {
    if (phone.length == 12 && phone.startsWith('+998')) {
      final digits = phone.substring(1);
      return '+998 ${digits.substring(0, 2)} ${digits.substring(2, 5)} ${digits.substring(5, 7)} ${digits.substring(7)}';
    }
    return phone;
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: NovaColors.amber.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 28, color: NovaColors.amberDeep),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: NovaColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: NovaColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 28,
                  color: NovaColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
