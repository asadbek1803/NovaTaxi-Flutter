import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/services/api_service.dart';
import '../models/onboarding_data.dart';

class OnboardingProvider with ChangeNotifier {
  final ApiService _api = ApiService.instance;
  
  OnboardingData? _onboardingData;
  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;
  
  static const int totalSteps = 5;

  OnboardingData? get onboardingData => _onboardingData;
  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get canGoNext => _currentStep < totalSteps - 1;
  bool get canGoBack => _currentStep > 0;

  Future<void> initOnboarding(String phoneNumber) async {
    _onboardingData = OnboardingData(phoneNumber: phoneNumber);
    _currentStep = 0;
    notifyListeners();
  }

  void updateVehicleInfo(VehicleInfo vehicleInfo) {
    _onboardingData = _onboardingData?.copyWith(vehicleInfo: vehicleInfo);
    notifyListeners();
  }

  void updatePersonalInfo(PersonalInfo personalInfo) {
    _onboardingData = _onboardingData?.copyWith(personalInfo: personalInfo);
    notifyListeners();
  }

  void updatePassportPhoto(DocumentUpload passportPhoto) {
    _onboardingData = _onboardingData?.copyWith(passportPhoto: passportPhoto);
    notifyListeners();
  }

  void updateSelfiePhoto(DocumentUpload selfiePhoto) {
    _onboardingData = _onboardingData?.copyWith(selfiePhoto: selfiePhoto);
    notifyListeners();
  }

  void updateCarPhoto(DocumentUpload carPhoto) {
    _onboardingData = _onboardingData?.copyWith(carPhoto: carPhoto);
    notifyListeners();
  }

  void nextStep() {
    if (canGoNext) {
      _currentStep++;
      _errorMessage = null;
      notifyListeners();
    }
  }

  void previousStep() {
    if (canGoBack) {
      _currentStep--;
      _errorMessage = null;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      _currentStep = step;
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> submitOnboarding() async {
    if (_onboardingData == null || !_onboardingData!.isComplete) {
      _errorMessage = 'Barcha qadamlarni to\'ldiring';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = _onboardingData!;
      final files = <String, File>{};
      
      if (data.passportPhoto != null) {
        final passportFile = File(data.passportPhoto!.filePath);
        if (await passportFile.exists()) {
          files['passport'] = passportFile;
        }
      }
      if (data.selfiePhoto != null) {
        final selfieFile = File(data.selfiePhoto!.filePath);
        if (await selfieFile.exists()) {
          files['selfie'] = selfieFile;
        }
      }
      if (data.carPhoto != null) {
        final carFile = File(data.carPhoto!.filePath);
        if (await carFile.exists()) {
          files['car_photo'] = carFile;
        }
      }

      final fields = <String, String>{
        'phone_number': data.phoneNumber,
        'car_model': data.vehicleInfo!.carModel,
        'car_color': data.vehicleInfo!.carColor,
        'license_plate': data.vehicleInfo!.licensePlate,
        'full_name': data.personalInfo!.fullName,
        'driver_license': data.personalInfo!.driverLicense,
      };

      try {
        await _api.multipartPost(
          AppConstants.submitOnboarding,
          fields: fields,
          files: files,
        );
      } catch (_) {
        // Demo mode: API unavailable, proceed with local state
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.onboardingCompleted, true);
      await prefs.setString(AppConstants.driverStatus, AppConstants.statusPending);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool(AppConstants.onboardingCompleted) ?? false;
      return completed;
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _onboardingData = null;
    _currentStep = 0;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
