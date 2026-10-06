import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/onboarding_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'vehicle_info_screen.dart';
import 'personal_info_screen.dart';
import 'passport_scanner_screen.dart';
import 'selfie_capture_screen.dart';
import 'car_photo_screen.dart';

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  @override
  void initState() {
    super.initState();
    _initializeOnboarding();
  }

  Future<void> _initializeOnboarding() async {
    final onboardingProvider = context.read<OnboardingProvider>();
    if (onboardingProvider.onboardingData != null) return;

    final authProvider = context.read<AuthProvider>();
    String phoneNumber = authProvider.driver?.phoneNumber ?? '';

    if (phoneNumber.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      phoneNumber = prefs.getString(AppConstants.phoneNumber) ?? '';
    }
    
    if (phoneNumber.isNotEmpty) {
      await onboardingProvider.initOnboarding(phoneNumber);
    }
  }

  Widget _buildStep(int step) {
    switch (step) {
      case 0:
        return const VehicleInfoScreen();
      case 1:
        return const PersonalInfoScreen();
      case 2:
        return const PassportScannerScreen();
      case 3:
        return const SelfieCaptureScreen();
      case 4:
        return const CarPhotoScreen();
      default:
        return const VehicleInfoScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        final currentStep = onboardingProvider.currentStep;

        return Scaffold(
          backgroundColor: NovaColors.backgroundLight,
          body: KeyedSubtree(
            key: ValueKey(currentStep),
            child: _buildStep(currentStep),
          ),
        );
      },
    );
  }
}
