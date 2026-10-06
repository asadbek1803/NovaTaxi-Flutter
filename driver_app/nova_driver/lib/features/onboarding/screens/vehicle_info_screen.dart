import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../models/onboarding_data.dart';
import '../providers/onboarding_provider.dart';

class VehicleInfoScreen extends StatefulWidget {
  const VehicleInfoScreen({super.key});

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _carModelController = TextEditingController();
  final _carColorController = TextEditingController();
  final _licensePlateController = TextEditingController();

  @override
  void dispose() {
    _carModelController.dispose();
    _carColorController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    if (!_formKey.currentState!.validate()) return;

    final vehicleInfo = VehicleInfo(
      carModel: _carModelController.text.trim(),
      carColor: _carColorController.text.trim(),
      licensePlate: _licensePlateController.text.trim().toUpperCase(),
    );

    context.read<OnboardingProvider>().updateVehicleInfo(vehicleInfo);
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
                      _buildCarModelField(),
                      const SizedBox(height: 16),
                      _buildCarColorField(),
                      const SizedBox(height: 16),
                      _buildLicensePlateField(),
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
            Icons.directions_car_rounded,
            size: 28,
            color: NovaColors.amber,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Avtomobil haqida',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Avtomobilingizning ma\'lumotlarini kiriting',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: NovaColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildCarModelField() {
    return _buildTextField(
      controller: _carModelController,
      label: 'Avtomobil modeli',
      hint: 'Masalan: Chevrolet Cobalt',
      icon: Icons.car_repair_rounded,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Avtomobil modelini kiriting';
        }
        if (value.trim().length < 3) {
          return 'Model nomi juda qisqa';
        }
        return null;
      },
    );
  }

  Widget _buildCarColorField() {
    return _buildTextField(
      controller: _carColorController,
      label: 'Avtomobil rangi',
      hint: 'Masalan: Oq',
      icon: Icons.palette_rounded,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Avtomobil rangini kiriting';
        }
        return null;
      },
    );
  }

  Widget _buildLicensePlateField() {
    return _buildTextField(
      controller: _licensePlateController,
      label: 'Davlat raqami',
      hint: 'Masalan: 01 A 777 BA',
      icon: Icons.confirmation_number_rounded,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9\s]')),
        UpperCaseTextFormatter(),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Davlat raqamini kiriting';
        }
        if (value.trim().length < 5) {
          return 'Davlat raqami noto\'g\'ri';
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
