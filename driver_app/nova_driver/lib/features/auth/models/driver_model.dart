class Driver {
  final String id;
  final String phoneNumber;
  final String? fullName;
  final String? driverLicense;
  final String status;
  final DateTime? createdAt;
  final String? rejectionReason;

  const Driver({
    required this.id,
    required this.phoneNumber,
    this.fullName,
    this.driverLicense,
    required this.status,
    this.createdAt,
    this.rejectionReason,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      fullName: json['full_name']?.toString(),
      driverLicense: json['driver_license']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      rejectionReason: json['rejection_reason']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'driver_license': driverLicense,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
    };
  }

  Driver copyWith({
    String? id,
    String? phoneNumber,
    String? fullName,
    String? driverLicense,
    String? status,
    DateTime? createdAt,
    String? rejectionReason,
  }) {
    return Driver(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      driverLicense: driverLicense ?? this.driverLicense,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isActive => status == 'active';
}
