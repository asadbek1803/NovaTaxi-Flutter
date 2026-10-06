import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NovaColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Ilova haqida',
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
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
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
                      gradient: const LinearGradient(
                        colors: [NovaColors.amber, NovaColors.amberDark],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: NovaColors.amber.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_taxi_rounded,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nova Haydovchi',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: NovaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Versiya 1.0.0 (1)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: NovaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: NovaColors.online.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Eng so\'nggi versiya',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: NovaColors.onlineDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _InfoCard(
              children: [
                _AboutRow(
                  icon: Icons.code_rounded,
                  label: 'Dastur tili',
                  value: 'Flutter (Dart)',
                ),
                const _Divider(),
                _AboutRow(
                  icon: Icons.phone_android_rounded,
                  label: 'Qo\'llab-quvvatlash',
                  value: 'Android 8.0+',
                ),
                const _Divider(),
                _AboutRow(
                  icon: Icons.build_rounded,
                  label: 'Build',
                  value: '2026.07.1',
                ),
                const _Divider(),
                _AboutRow(
                  icon: Icons.storage_rounded,
                  label: 'Server',
                  value: 'api.novataxi.uz',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoCard(
              children: [
                _TapRow(
                  icon: Icons.description_rounded,
                  label: 'Foydalanish shartlari',
                  onTap: () => _openUrl(context, 'https://novataxi.uz/terms'),
                ),
                const _Divider(),
                _TapRow(
                  icon: Icons.privacy_tip_rounded,
                  label: 'Maxfiylik siyosati',
                  onTap: () => _openUrl(context, 'https://novataxi.uz/privacy'),
                ),
                const _Divider(),
                _TapRow(
                  icon: Icons.gavel_rounded,
                  label: 'Litsenziyalar (Open Source)',
                  onTap: () => _showLicenses(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoCard(
              children: [
                _TapRow(
                  icon: Icons.star_rounded,
                  label: 'Ilovani baholash',
                  onTap: () => _openUrl(context, 'https://play.google.com/store/apps/details?id=com.novataxi.driver'),
                ),
                const _Divider(),
                _TapRow(
                  icon: Icons.share_rounded,
                  label: 'Do\'stlarga ulashish',
                  onTap: () => _shareApp(),
                ),
                const _Divider(),
                _TapRow(
                  icon: Icons.update_rounded,
                  label: 'Yangilanishlarni tekshirish',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Eng so\'nggi versiya o\'rnatilgan!',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Nova Taxi © 2026',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: NovaColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Barcha huquqlar himoyalangan.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: NovaColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareApp() {
    // In production: Share.share('Nova Taxi haydovchi ilovasi: https://play.google.com/store/apps/details?id=com.novataxi.driver');
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'Nova Haydovchi',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Nova Taxi',
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AboutRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: NovaColors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: NovaColors.amberDeep),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: NovaColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: NovaColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TapRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TapRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: NovaColors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: NovaColors.amberDeep),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: NovaColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: NovaColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFFF3F4F6),
    );
  }
}
