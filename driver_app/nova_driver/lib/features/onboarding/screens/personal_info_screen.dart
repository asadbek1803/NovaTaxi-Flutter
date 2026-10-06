import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../models/onboarding_data.dart';
import '../providers/onboarding_provider.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _driverLicenseController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _driverLicenseController.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    if (!_formKey.currentState!.validate()) return;

    final personalInfo = PersonalInfo(
      fullName: _fullNameController.text.trim(),
      driverLicense: _driverLicenseController.text.trim().toUpperCase(),
    );

    context.read<OnboardingProvider>().updatePersonalInfo(personalInfo);
    context.read<OnboardingProvider>().nextStep();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NovaColors.backgroundLight,
      appBar: _buildAppBar(),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildFullNameField(),
                      const SizedBox(height: 16),
                      _buildDriverLicenseField(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: _buildContinueButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: NovaColors.backgroundLight,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => context.read<OnboardingProvider>().previousStep(),
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
            Icons.person_rounded,
            size: 28,
            color: NovaColors.amber,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Shaxsiy ma\'lumotlar',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'O\'zingiz haqingizda ma\'lumotlarni kiriting',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: NovaColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildFullNameField() {
    return _buildTextField(
      controller: _fullNameController,
      label: 'F.I.O',
      hint: 'Masalan: Toshmatov Qodir',
      icon: Icons.badge_rounded,
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'F.I.O ni kiriting';
        }
        final parts = value.trim().split(' ');
        if (parts.length < 2) {
          return 'Ism va familiyani kiriting';
        }
        return null;
      },
    );
  }

  Widget _buildDriverLicenseField() {
    return _buildTextField(
      controller: _driverLicenseController,
      label: 'Haydovchilik guvohnomasi raqami',
      hint: 'Masalan: AA 1234567',
      icon: Icons.credit_card_rounded,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9\s]')),
        UpperCaseTextFormatter(),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Haydovchilik guvohnomasi raqamini kiriting';
        }
        if (value.trim().length < 5) {
          return 'Guvohnoma raqami noto\'g\'ri';
        }
        return null;
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: NovaColors.textSecondary.withValues(alpha: 0.5),
              ),
              prefixIcon: Icon(icon, color: NovaColors.amber),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
            ),
            inputFormatters: inputFormatters,
            textCapitalization: textCapitalization,
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _saveAndContinue,
        child: const Text('Davom etish'),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
