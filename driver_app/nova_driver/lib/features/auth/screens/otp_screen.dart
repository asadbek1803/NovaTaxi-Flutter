import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _resendSeconds = AppConstants.otpResendDelaySeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = AppConstants.otpResendDelaySeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOtp(_pinController.text);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      _navigateBasedOnStatus(authProvider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Kod noto\'g\'ri'),
          backgroundColor: NovaColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateBasedOnStatus(AuthProvider authProvider) {
    final driver = authProvider.driver;
    
    if (driver == null) {
      Navigator.pushReplacementNamed(context, '/onboarding');
      return;
    }

    switch (driver.status) {
      case AppConstants.statusPending:
        Navigator.pushReplacementNamed(context, '/pending');
        break;
      case AppConstants.statusApproved:
      case AppConstants.statusActive:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case AppConstants.statusRejected:
        Navigator.pushReplacementNamed(context, '/onboarding');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  Future<void> _resendOtp() async {
    if (_resendSeconds > 0) return;

    final authProvider = context.read<AuthProvider>();
    final prefs = await authProvider.sendOtp('');

    if (mounted && prefs) {
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SMS qayta yuborildi'),
          backgroundColor: NovaColors.online,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NovaColors.backgroundLight,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 36),
                      _buildOtpInput(),
                      const SizedBox(height: 20),
                      _buildResendButton(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: _buildVerifyButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: NovaColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'SMS kodni kiriting',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          '${AppConstants.defaultCountryCode} XX XXX XX XX raqamiga yuborilgan kodni kiriting',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: NovaColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 64,
      textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: NovaColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NovaColors.textSecondary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NovaColors.amber, width: 2),
        boxShadow: [
          BoxShadow(
            color: NovaColors.amber.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    return Center(
      child: Pinput(
        controller: _pinController,
        length: AppConstants.otpLength,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: focusedPinTheme,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        validator: (value) {
          if (value == null || value.length != AppConstants.otpLength) {
            return '6 xonali kodni kiriting';
          }
          return null;
        },
        onCompleted: (value) => _verifyOtp(),
      ),
    );
  }

  Widget _buildResendButton() {
    return Center(
      child: TextButton(
        onPressed: _resendSeconds > 0 ? null : _resendOtp,
        child: Text(
          _resendSeconds > 0
              ? 'Kodni qayta yuborish ($_resendSeconds soniya)'
              : 'Kodni qayta yuborish',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _resendSeconds > 0
                ? NovaColors.textSecondary
                : NovaColors.amber,
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isLoading 
              ? NovaColors.textSecondary 
              : NovaColors.amber,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Tasdiqlash'),
      ),
    );
  }
}
