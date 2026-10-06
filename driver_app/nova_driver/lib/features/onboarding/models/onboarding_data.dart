class VehicleInfo {
  String carModel;
  String carColor;
  String licensePlate;

  VehicleInfo({
    required this.carModel,
    required this.carColor,
    required this.licensePlate,
  });

  Map<String, dynamic> toJson() {
    return {
      'car_model': carModel,
      'car_color': carColor,
      'license_plate': licensePlate,
    };
  }

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      carModel: json['car_model']?.toString() ?? '',
      carColor: json['car_color']?.toString() ?? '',
      licensePlate: json['license_plate']?.toString() ?? '',
    );
  }
}

class PersonalInfo {
  String fullName;
  String driverLicense;

  PersonalInfo({
    required this.fullName,
    required this.driverLicense,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'driver_license': driverLicense,
    };
  }

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      fullName: json['full_name']?.toString() ?? '',
      driverLicense: json['driver_license']?.toString() ?? '',
    );
  }
}

class DocumentUpload {
  final String type;
  final String filePath;
  final String? fileName;

  DocumentUpload({
    required this.type,
    required this.filePath,
    this.fileName,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'file_path': filePath,
      'file_name': fileName,
    };
  }
}

class OnboardingData {
  final String phoneNumber;
  VehicleInfo? vehicleInfo;
  PersonalInfo? personalInfo;
  DocumentUpload? passportPhoto;
  DocumentUpload? selfiePhoto;
  DocumentUpload? carPhoto;

  OnboardingData({
    required this.phoneNumber,
    this.vehicleInfo,
    this.personalInfo,
    this.passportPhoto,
    this.selfiePhoto,
    this.carPhoto,
  });

  bool get isComplete {
    return vehicleInfo != null &&
           personalInfo != null &&
           passportPhoto != null &&
           selfiePhoto != null &&
           carPhoto != null;
  }

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'vehicle_info': vehicleInfo?.toJson(),
      'personal_info': personalInfo?.toJson(),
      'passport_photo': passportPhoto?.toJson(),
      'selfie_photo': selfiePhoto?.toJson(),
      'car_photo': carPhoto?.toJson(),
    };
  }

  OnboardingData copyWith({
    String? phoneNumber,
    VehicleInfo? vehicleInfo,
    PersonalInfo? personalInfo,
    DocumentUpload? passportPhoto,
    DocumentUpload? selfiePhoto,
    DocumentUpload? carPhoto,
  }) {
    return OnboardingData(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      personalInfo: personalInfo ?? this.personalInfo,
      passportPhoto: passportPhoto ?? this.passportPhoto,
      selfiePhoto: selfiePhoto ?? this.selfiePhoto,
      carPhoto: carPhoto ?? this.carPhoto,
    );
  }
}
