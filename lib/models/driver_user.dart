class DriverUser {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  final String nicNumber;
  final String drivingLicenseNumber;
  final VehicleType vehicleType;
  final String? profilePhotoUrl;
  final List<String> documentUrls;
  final bool isVerified;
  final DateTime createdAt;

  DriverUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.nicNumber,
    required this.drivingLicenseNumber,
    required this.vehicleType,
    this.profilePhotoUrl,
    this.documentUrls = const [],
    this.isVerified = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'nicNumber': nicNumber,
      'drivingLicenseNumber': drivingLicenseNumber,
      'vehicleType': vehicleType.toString(),
      'profilePhotoUrl': profilePhotoUrl,
      'documentUrls': documentUrls,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DriverUser.fromJson(Map<String, dynamic> json) {
    return DriverUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      nicNumber: json['nicNumber'],
      drivingLicenseNumber: json['drivingLicenseNumber'],
      vehicleType: VehicleType.values.firstWhere(
        (e) => e.toString() == json['vehicleType'],
      ),
      profilePhotoUrl: json['profilePhotoUrl'],
      documentUrls: List<String>.from(json['documentUrls'] ?? []),
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

enum VehicleType {
  bike,
  threeWheel,
  car,
  miniVan,
  dualPurpose,
}

extension VehicleTypeExtension on VehicleType {
  String get displayName {
    switch (this) {
      case VehicleType.bike:
        return 'Bike';
      case VehicleType.threeWheel:
        return 'Three Wheel';
      case VehicleType.car:
        return 'Car';
      case VehicleType.miniVan:
        return 'Mini Van';
      case VehicleType.dualPurpose:
        return 'Dual Purpose Vehicle';
    }
  }

  String get icon {
    switch (this) {
      case VehicleType.bike:
        return '🏍️';
      case VehicleType.threeWheel:
        return '🛺';
      case VehicleType.car:
        return '🚗';
      case VehicleType.miniVan:
        return '🚐';
      case VehicleType.dualPurpose:
        return '🚙';
    }
  }
}
