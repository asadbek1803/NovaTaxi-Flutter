import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/services/api_service.dart';
import '../models/driver_model.dart';

enum AuthStatus {
  uninitialized,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  final ApiService _api = ApiService.instance;
  
  AuthStatus _status = AuthStatus.uninitialized;
  Driver? _driver;
  String? _errorMessage;
  
  AuthStatus get status => _status;
  Driver? get driver => _driver;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.accessToken);
      final driverId = prefs.getString(AppConstants.driverId);
      
      if (token != null && driverId != null) {
        _api.setAccessToken(token);
        await _fetchDriverStatus();
      } else {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> _fetchDriverStatus() async {
    try {
      final response = await _api.get(AppConstants.getDriverStatus);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.driverStatus, (data['status'] ?? 'pending') as String);
      
      _driver = Driver.fromJson(data);
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      await _clearAuthData();
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> sendOtp(String phoneNumber) async {
    _errorMessage = null;

    try {
      final formattedPhone = _formatPhoneNumber(phoneNumber);
      
      await _api.post(AppConstants.sendOtp, body: {
        'phone_number': formattedPhone,
      });
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.phoneNumber, formattedPhone);
      
      return true;
    } catch (e) {
      // Demo mode: save phone and proceed even if API fails
      try {
        final formattedPhone = _formatPhoneNumber(phoneNumber);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.phoneNumber, formattedPhone);
      } catch (_) {}
      return true;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString(AppConstants.phoneNumber);
      
      if (phoneNumber == null) {
        throw Exception('Phone number not found');
      }
      
      final response = await _api.post(AppConstants.verifyOtp, body: {
        'phone_number': phoneNumber,
        'otp': otp,
      });
      
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['access_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;
      
      if (token != null) {
        await _saveAuthData(token, refreshToken ?? '', data);
        _api.setAccessToken(token);
        await _fetchDriverStatus();
        return true;
      }
      
      return false;
    } catch (e) {
      // Demo mode: go to onboarding when API fails
      _driver = null;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    }
  }

  Future<bool> registerDriver(Map<String, dynamic> data) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.post(AppConstants.registerDriver, body: data);
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      final token = responseData['access_token'] as String?;
      final refreshToken = responseData['refresh_token'] as String?;
      
      if (token != null) {
        await _saveAuthData(token, refreshToken ?? '', responseData);
        _api.setAccessToken(token);
        await _fetchDriverStatus();
        return true;
      }
      
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _clearAuthData();
    _status = AuthStatus.unauthenticated;
    _driver = null;
    _api.setAccessToken(null);
    notifyListeners();
  }

  Future<void> updateDriverStatus(String status) async {
    _driver = _driver?.copyWith(status: status);
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.driverStatus, status);
  }

  String _formatPhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleanPhone.startsWith('+998')) {
      return cleanPhone;
    }
    if (cleanPhone.startsWith('998')) {
      return '+$cleanPhone';
    }
    return '+998$cleanPhone';
  }

  Future<void> _saveAuthData(
    String token,
    String refreshToken,
    Map<String, dynamic> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.accessToken, token);
    await prefs.setString(AppConstants.refreshToken, refreshToken);
    
    if (data['driver_id'] != null) {
      await prefs.setString(AppConstants.driverId, data['driver_id'].toString());
    }
    
    if (data['phone_number'] != null) {
      await prefs.setString(AppConstants.phoneNumber, data['phone_number']);
    }
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.accessToken);
    await prefs.remove(AppConstants.refreshToken);
    await prefs.remove(AppConstants.driverId);
    await prefs.remove(AppConstants.driverStatus);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
