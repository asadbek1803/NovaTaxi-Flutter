import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NovaColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Yordam',
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    NovaColors.amber.withValues(alpha: 0.15),
                    NovaColors.amberLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: NovaColors.amber.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.support_agent_rounded,
                    size: 56,
                    color: NovaColors.amberDeep,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Qo\'llab-quvvatlash markazi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: NovaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '24/7 qo\'llab-quvvatlash xizmati',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: NovaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tezkor bog\'lanish',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: NovaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ContactCard(
                    icon: Icons.phone_rounded,
                    title: 'Qo\'ng\'iroq',
                    subtitle: '+998 90 123 45 67',
                    color: NovaColors.online,
                    onTap: () => _makePhoneCall('+998901234567'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ContactCard(
                    icon: Icons.chat_rounded,
                    title: 'Chat',
                    subtitle: 'Onlayn',
                    color: const Color(0xFF3B82F6),
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ContactCard(
                    icon: Icons.email_rounded,
                    title: 'Email',
                    subtitle: 'nova@taxi.uz',
                    color: NovaColors.amberDeep,
                    onTap: () => _sendEmail('nova@taxi.uz'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ContactCard(
                    icon: Icons.telegram_rounded,
                    title: 'Telegram',
                    subtitle: '@novataxi',
                    color: const Color(0xFF0088CC),
                    onTap: () => _openTelegram('@novataxi'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Ko\'p beriladigan savollar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: NovaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(_faqItems.length, (index) {
              final item = _faqItems[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
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
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: NovaColors.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.help_outline_rounded, size: 22, color: NovaColors.amberDeep),
                    ),
                    title: Text(
                      item['q']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: NovaColors.textPrimary,
                      ),
                    ),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['a']!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: NovaColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            const Text(
              'Muammo xabar berish',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: NovaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Xabaringizni yozing',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: NovaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    maxLines: 4,
                    style: const TextStyle(
                      fontSize: 16,
                      color: NovaColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Muammoni batafsil yozing...',
                      hintStyle: const TextStyle(fontSize: 15, color: Color(0xFFBDBDBD)),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: NovaColors.amber, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Xabaringiz yuborildi!',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text(
                        'YUBORISH',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email?subject=Nova Taxi Haydovchi Yordam');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openTelegram(String username) async {
    final uri = Uri.parse('https://t.me/${username.substring(1)}');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
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
    );
  }
}

const List<Map<String, String>> _faqItems = [
  {
    'q': 'Qanday qilib onlayn bo\'lish mumkin?',
    'a': 'Asosiy ekrandagi "CHIQISH (ONLAYN)" tugmasini bosing. Yashil nuqta paydo bo\'lganda siz onlayn rejimdasiz va buyurtmalar qabul qila olasiz.',
  },
  {
    'q': 'Buyurtma qanday keladi?',
    'a': 'Onlayn bo\'lganingizdan so\'ng, yaqin atrofdagi buyurtmalar avtomatik ravishda telefoningizga keladi. Ovozli bildirishnoma ham chalinishi mumkin.',
  },
  {
    'q': 'Narxlar qanday belgilanadi?',
    'a': 'Narxlar tizim tomonidan masofa va vaqtga qarab avtomatik hisoblanadi. Siz faqat mijozni manzilga yetkazishingiz kerak.',
  },
  {
    'q': 'Qanday qilib pul yechish mumkin?',
    'a': 'Profil → To\'lov bo\'limiga boring. "Pul yechish" tugmasini bosib, miqdorni va kartani tanlang. 1-3 ish kunida pul o\'tkaziladi.',
  },
  {
    'q': 'Hujjatlarim rad etilsa nima qilish kerak?',
    'a': 'Rad etilgan holda "Qayta yuborish" tugmasini bosishingiz mumkin. Yangi rasmlar yuklang va qayta tekshirishga yuboring.',
  },
  {
    'q': 'Hisobni qanday o\'chirish mumkin?',
    'a': 'Sozlamalar → Hisob bo\'limidan "Hisobni o\'chirish" tugmasini bosing. Bu amal qaytarib bo\'lmaydi.',
  },
  {
    'q': 'Qo\'llab-quvvatlash bilan qanday bog\'lanish mumkin?',
    'a': 'Yordam sahifasidagi telefon, chat, email yoki Telegram orqali 24/7 bog\'lanishingiz mumkin.',
  },
];
