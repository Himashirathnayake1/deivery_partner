import '../models/driver_user.dart';

class AuthService {
  // Dummy credentials for testing
  static const Map<String, String> _dummyCredentials = {
    'pegas': '123456',
    'demo@driver.com': 'password123',
    '+94712345678': 'password123',
    'john@example.com': 'john123',
    '+94987654321': 'john123',
  };

  static final Map<String, DriverUser> _dummyUsers = {
    'pegas': DriverUser(
      id: '0',
      name: 'Pegas',
      email: 'pegas@driver.com',
      phoneNumber: '+94700000000',
      address: '456 Pegas Street, Colombo',
      nicNumber: '199000000000',
      drivingLicenseNumber: 'P1234567',
      vehicleType: VehicleType.bike,
      isVerified: true,
      createdAt: DateTime(2023, 1, 1),
    ),
    'demo@driver.com': DriverUser(
      id: '1',
      name: 'Demo Driver',
      email: 'demo@driver.com',
      phoneNumber: '+94712345678',
      address: '123 Main Street, Colombo',
      nicNumber: '199512345678',
      drivingLicenseNumber: 'B1234567',
      vehicleType: VehicleType.bike,
      isVerified: true,
      createdAt: DateTime(2023, 1, 1),
    ),
    '+94712345678': DriverUser(
      id: '1',
      name: 'Demo Driver',
      email: 'demo@driver.com',
      phoneNumber: '+94712345678',
      address: '123 Main Street, Colombo',
      nicNumber: '199512345678',
      drivingLicenseNumber: 'B1234567',
      vehicleType: VehicleType.bike,
      isVerified: true,
      createdAt: DateTime(2023, 1, 1),
    ),
  };

  // Login with email or phone number
  static Future<AuthResult> login(String identifier, String password) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    
    if (_dummyCredentials.containsKey(identifier) && 
        _dummyCredentials[identifier] == password) {
      return AuthResult(
        success: true,
        user: _dummyUsers[identifier]!,
        message: 'Login successful',
      );
    }
    
    return AuthResult(
      success: false,
      message: 'Invalid credentials',
    );
  }

  // Register new user
  static Future<AuthResult> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String address,
    required String nicNumber,
    required String drivingLicenseNumber,
    required VehicleType vehicleType,
    required String password,
    String? profilePhotoUrl,
    List<String> documentUrls = const [],
  }) async {
    await Future.delayed(const Duration(seconds: 3)); // Simulate API call
    
    // Check if user already exists
    if (_dummyCredentials.containsKey(email) || 
        _dummyCredentials.containsKey(phoneNumber)) {
      return AuthResult(
        success: false,
        message: 'User already exists with this email or phone number',
      );
    }
    
    final user = DriverUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      nicNumber: nicNumber,
      drivingLicenseNumber: drivingLicenseNumber,
      vehicleType: vehicleType,
      profilePhotoUrl: profilePhotoUrl,
      documentUrls: documentUrls,
      createdAt: DateTime.now(),
    );
    
    return AuthResult(
      success: true,
      user: user,
      message: 'Registration successful. Please wait for verification.',
    );
  }

  // Forgot password - send OTP
  static Future<AuthResult> sendPasswordResetOTP(String identifier) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    
    if (_dummyCredentials.containsKey(identifier)) {
      return AuthResult(
        success: true,
        message: 'OTP sent successfully to your registered contact.',
      );
    }
    
    return AuthResult(
      success: false,
      message: 'No account found with this identifier',
    );
  }

  // Verify OTP and reset password
  static Future<AuthResult> resetPassword({
    required String identifier,
    required String otp,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    
    // For demo, accept any 6-digit OTP
    if (otp.length == 6 && _dummyCredentials.containsKey(identifier)) {
      return AuthResult(
        success: true,
        message: 'Password reset successful',
      );
    }
    
    return AuthResult(
      success: false,
      message: 'Invalid OTP or identifier',
    );
  }

  // Verify last 4 digits of license for password recovery
  static Future<AuthResult> verifyLicenseDigits({
    required String identifier,
    required String lastFourDigits,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    
    // For demo purposes, accept "4567" as valid last 4 digits
    if (lastFourDigits == "4567" && _dummyCredentials.containsKey(identifier)) {
      return AuthResult(
        success: true,
        message: 'License verification successful',
      );
    }
    
    return AuthResult(
      success: false,
      message: 'Invalid license digits',
    );
  }
}

class AuthResult {
  final bool success;
  final DriverUser? user;
  final String message;

  AuthResult({
    required this.success,
    this.user,
    required this.message,
  });
}

// Form validation utilities
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^\+94[0-9]{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number (+94XXXXXXXXX)';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateNIC(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIC number is required';
    }
    
    final nicRegex = RegExp(r'^[0-9]{9}[vVxX]$|^[0-9]{12}$');
    if (!nicRegex.hasMatch(value)) {
      return 'Please enter a valid NIC number';
    }
    
    return null;
  }

  static String? validateLicenseNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Driving license number is required';
    }
    
    if (value.length < 5) {
      return 'Please enter a valid license number';
    }
    
    return null;
  }
}
