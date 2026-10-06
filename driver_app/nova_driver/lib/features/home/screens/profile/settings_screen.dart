import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _autoAccept = false;
  bool _darkMode = false;
  String _selectedLanguage = 'O\'zbek';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NovaColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Sozlamalar',
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
            _SectionHeader(title: 'Bildirishnomalar'),
            _SettingsCard(
              children: [
                _SwitchTile(
                  icon: Icons.notifications_rounded,
                  title: 'Bildirishnomalar',
                  subtitle: 'Push xabarnomalar',
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                ),
                const _Divider(),
                _SwitchTile(
                  icon: Icons.volume_up_rounded,
                  title: 'Ovoz',
                  subtitle: 'Buyurtma ovozi',
                  value: _soundEnabled,
                  onChanged: (v) => setState(() => _soundEnabled = v),
                ),
                const _Divider(),
                _SwitchTile(
                  icon: Icons.vibration_rounded,
                  title: 'Vibratsiya',
                  subtitle: 'Tebranish effektlari',
                  value: _vibrationEnabled,
                  onChanged: (v) => setState(() => _vibrationEnabled = v),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SectionHeader(title: 'Ish rejimi'),
            _SettingsCard(
              children: [
                _SwitchTile(
                  icon: Icons.autorenew_rounded,
                  title: 'Avtomatik qabul qilish',
                  subtitle: 'Buyurtmalarni avtomatik qabul qilish',
                  value: _autoAccept,
                  onChanged: (v) => setState(() => _autoAccept = v),
                ),
                const _Divider(),
                _TapTile(
                  icon: Icons.speed_rounded,
                  title: 'Minimal masofa',
                  subtitle: '2 km',
                  onTap: () => _showMinDistanceDialog(context),
                ),
                const _Divider(),
                _TapTile(
                  icon: Icons.attach_money_rounded,
                  title: 'Minimal narx',
                  subtitle: '5 000 so\'m',
                  onTap: () => _showMinPriceDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SectionHeader(title: 'Ko\'rinish'),
            _SettingsCard(
              children: [
                _SwitchTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Qorong\'u rejim',
                  subtitle: 'Tungi tema',
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                ),
                const _Divider(),
                _TapTile(
                  icon: Icons.language_rounded,
                  title: 'Til',
                  subtitle: _selectedLanguage,
                  onTap: () => _showLanguageDialog(context),
                ),
                const _Divider(),
                _TapTile(
                  icon: Icons.format_size_rounded,
                  title: 'Shrift kattaligi',
                  subtitle: 'Oddiy',
                  onTap: () => _showFontSizeDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SectionHeader(title: 'Xavfsizlik'),
            _SettingsCard(
              children: [
                _TapTile(
                  icon: Icons.lock_rounded,
                  title: 'PIN-kod',
                  subtitle: 'Ilovani bloklash',
                  onTap: () {},
                ),
                const _Divider(),
                _TapTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometrik kirish',
                  subtitle: 'Barmoq izi',
                  onTap: () {},
                ),
                const _Divider(),
                _TapTile(
                  icon: Icons.location_on_rounded,
                  title: 'Joylashuv ruxsati',
                  subtitle: 'Doimiy',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SectionHeader(title: 'Hisob'),
            _SettingsCard(
              children: [
                _TapTile(
                  icon: Icons.logout_rounded,
                  title: 'Chiqish',
                  subtitle: 'Hisobdan chiqish',
                  textColor: NovaColors.danger,
                  iconColor: NovaColors.danger,
                  onTap: () => _showLogoutDialog(context),
                ),
                const _Divider(),
                _TapTile(
                  icon: Icons.delete_forever_rounded,
                  title: 'Hisobni o\'chirish',
                  subtitle: 'Butunlay o\'chirish',
                  textColor: NovaColors.danger,
                  iconColor: NovaColors.danger,
                  onTap: () => _showDeleteDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Tilni tanlang', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(label: 'O\'zbek', selected: _selectedLanguage == "O'zbek",
                onTap: () { setState(() => _selectedLanguage = "O'zbek"); Navigator.pop(ctx); }),
            _LanguageOption(label: 'Русский', selected: _selectedLanguage == 'Русский',
                onTap: () { setState(() => _selectedLanguage = 'Русский'); Navigator.pop(ctx); }),
            _LanguageOption(label: 'English', selected: _selectedLanguage == 'English',
                onTap: () { setState(() => _selectedLanguage = 'English'); Navigator.pop(ctx); }),
          ],
        ),
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Shrift kattaligi', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(label: 'Kichik', selected: false, onTap: () => Navigator.pop(ctx)),
            _LanguageOption(label: 'Oddiy', selected: true, onTap: () => Navigator.pop(ctx)),
            _LanguageOption(label: 'Katta', selected: false, onTap: () => Navigator.pop(ctx)),
            _LanguageOption(label: 'Juda katta', selected: false, onTap: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    );
  }

  void _showMinDistanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Minimal masofa', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(label: '1 km', selected: false, onTap: () => Navigator.pop(ctx)),
            _LanguageOption(label: '2 km', selected: true, onTap: () => Navigator.pop(ctx)),
            _LanguageOption(label: '3 km', selected: false, onTap: () => Navigator.pop(ctx)),
            _LanguageOption(label: '5 km', selected: false, onTap: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    );
  }

  void _showMinPriceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Minimal narx', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(label: '3 000 so\'m', selected: false, onTap: () => Navigator.pop(ctx)),
            _LanguageOption(label: '5 000 so\'m', selected: true, onTap: () => Navigator.pop(ctx)),
            _LanguageOption(label: '8 000 so\'m', selected: false, onTap: () => Navigator.pop(ctx)),
            _LanguageOption(label: '10 000 so\'m', selected: false, onTap: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Chiqish', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Haqiqatan ham hisobdan chiqmoqchimisiz?',
            style: TextStyle(fontSize: 16, height: 1.4)),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor', style: TextStyle(
                fontSize: 16, color: NovaColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NovaColors.danger,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Chiqish', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Hisobni o\'chirish', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
          'Bu amal qaytarib bo\'lmaydi. Barcha ma\'lumotlaringiz, tarixingiz va hisobingiz butunlay o\'chiriladi.',
          style: TextStyle(fontSize: 16, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor', style: TextStyle(
                fontSize: 16, color: NovaColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: NovaColors.danger,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('O\'chirish', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: NovaColors.textPrimary,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

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

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: NovaColors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: NovaColors.amberDeep),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: NovaColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: NovaColors.online,
            inactiveTrackColor: NovaColors.offline,
          ),
        ],
      ),
    );
  }
}

class _TapTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  const _TapTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = textColor ?? NovaColors.textPrimary;
    final iconCol = iconColor ?? NovaColors.amberDeep;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (iconColor ?? NovaColors.amberDeep).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: iconCol),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: NovaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: iconColor != null ? NovaColors.danger : NovaColors.textSecondary,
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

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: NovaColors.online)
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
