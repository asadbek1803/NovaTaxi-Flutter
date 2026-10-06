import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'otp_screen.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final _phoneController = TextEditingController();
  final _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _rawDigits => _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');

  Future<void> _sendOtp() async {
    if (_rawDigits.length != AppConstants.phoneNumberLength) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);
    _focusNode.unfocus();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendOtp(_rawDigits);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OtpScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Xatolik yuz berdi'),
          backgroundColor: NovaColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = _rawDigits.length == AppConstants.phoneNumberLength;

    return Scaffold(
      backgroundColor: NovaColors.backgroundLight,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 48),
                      _buildPhoneInput(isComplete),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: _buildContinueButton(isComplete),
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
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: NovaColors.amber.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.phone_android_rounded,
            size: 28,
            color: NovaColors.amber,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Telefon raqamingiz',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Nova Taxi haydovchisi bo\'lish uchun telefon raqamingizni kiriting',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: NovaColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput(bool isComplete) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _phoneController,
        focusNode: _focusNode,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _sendOtp(),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(AppConstants.phoneNumberLength),
        ],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppConstants.defaultCountryCode,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: NovaColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 28,
                  color: NovaColors.textSecondary.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          hintText: '90 123 45 67',
          hintStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: NovaColors.textSecondary.withValues(alpha: 0.4),
            letterSpacing: 1.5,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          suffixIcon: _rawDigits.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: NovaColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    _phoneController.clear();
                    setState(() {});
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildContinueButton(bool isComplete) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: (_isLoading || !isComplete) ? null : _sendOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: isComplete ? NovaColors.amber : NovaColors.textSecondary,
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
            : const Text('Davom etish'),
      ),
    );
  }
}
