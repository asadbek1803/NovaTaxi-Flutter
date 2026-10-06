import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/onboarding_provider.dart';
import '../../auth/providers/auth_provider.dart';

class PendingStatusScreen extends StatefulWidget {
  const PendingStatusScreen({super.key});

  @override
  State<PendingStatusScreen> createState() => _PendingStatusScreenState();
}

class _PendingStatusScreenState extends State<PendingStatusScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Timer? _demoTimer;
  int _secondsLeft = 20;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _startDemoTimer();
  }

  void _startDemoTimer() {
    _demoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        _approveAndNavigate();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _approveAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.driverStatus, AppConstants.statusApproved);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NovaColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              _buildAnimatedIcon(),
              const SizedBox(height: 32),
              _buildTitle(),
              const SizedBox(height: 16),
              _buildDescription(),
              const SizedBox(height: 32),
              _buildCountdown(),
              const SizedBox(height: 16),
              _buildInfoCards(),
              const SizedBox(height: 24),
              _buildLogoutButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: NovaColors.amber.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.hourglass_empty_rounded,
          size: 64,
          color: NovaColors.amber,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Tekshiruv kutilmoqda',
      style: Theme.of(context).textTheme.headlineLarge,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    return Text(
      'Sizning ma\'lumotlaringiz moderator tomonidan tekshirilmoqda.\nNatija haqida bildirishnoma keladi.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: NovaColors.textSecondary,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCountdown() {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: _secondsLeft / 20,
                strokeWidth: 4,
                backgroundColor: NovaColors.amber.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(NovaColors.amber),
              ),
              Center(
                child: Text(
                  '$_secondsLeft',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: NovaColors.amber,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tasdiqlanish uchun $_secondsLeft soniya',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: NovaColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    return Column(
      children: [
        _buildInfoCard(
          icon: Icons.access_time_rounded,
          title: 'O\'rtacha vaqt',
          description: '1-2 ish kuni',
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          icon: Icons.notifications_active_rounded,
          title: 'Bildirishnoma',
          description: 'Natija bo\'yicha SMS yuboriladi',
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          icon: Icons.phone_rounded,
          title: 'Qo\'llab-quvvatlash',
          description: '+998 90 123 45 67',
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: NovaColors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: NovaColors.amber,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: NovaColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return TextButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => _buildLogoutDialog(),
        );
      },
      child: Text(
        'Chiqish',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: NovaColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildLogoutDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Chiqish'),
      content: const Text('Haqiqatan ham chiqmoqchimisiz?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Bekor qilish'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<AuthProvider>().logout();
            Navigator.pushReplacementNamed(context, '/login');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: NovaColors.danger,
          ),
          child: const Text('Chiqish'),
        ),
      ],
    );
  }
}

class RejectionScreen extends StatelessWidget {
  const RejectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final rejectionReason = authProvider.driver?.rejectionReason ?? 
        'Ma\'lumotlaringiz tasdiqlanmadi. Qayta yuborishingiz mumkin.';

    return Scaffold(
      backgroundColor: NovaColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: NovaColors.danger.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_rounded,
                  size: 64,
                  color: NovaColors.danger,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Ariza rad qilindi',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: NovaColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: NovaColors.danger.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  rejectionReason,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: NovaColors.danger,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<OnboardingProvider>().reset();
                    Navigator.pushReplacementNamed(context, '/onboarding');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NovaColors.amber,
                  ),
                  child: const Text('Qayta yuborish'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Chiqish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
