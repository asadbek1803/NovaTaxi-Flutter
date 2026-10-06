class AppConstants {
  AppConstants._();

  // API Configuration
  static const String baseUrl = 'https://api.novataxi.uz';
  static const String apiVersion = '/v1';
  
  // API Endpoints
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String registerDriver = '/auth/register';
  static const String uploadDocument = '/documents/upload';
  static const String submitOnboarding = '/drivers/onboarding';
  static const String getDriverStatus = '/drivers/status';
  
  // Storage Keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String phoneNumber = 'phone_number';
  static const String driverId = 'driver_id';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String driverStatus = 'driver_status';
  
  // Driver Status
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  static const String statusActive = 'active';
  static const String statusInactive = 'inactive';
  
  // Phone Format
  static const String defaultCountryCode = '+998';
  static const int phoneNumberLength = 9;
  
  // OTP Configuration
  static const int otpLength = 6;
  static const int otpResendDelaySeconds = 60;
  
  // Document Types
  static const String docPassport = 'passport';
  static const String docDriverLicense = 'driver_license';
  static const String docSelfie = 'selfie';
  static const String docCarPhoto = 'car_photo';
  
  // WebSocket
  static const String wsBaseUrl = 'wss://api.novataxi.uz';

  // Map defaults (Tashkent center)
  static const double defaultLat = 41.2995;
  static const double defaultLng = 69.2401;
  static const double defaultZoom = 15.0;

  // Image Quality
  static const int imageQuality = 85;
  static const double maxImageSizeMB = 5.0;
}
