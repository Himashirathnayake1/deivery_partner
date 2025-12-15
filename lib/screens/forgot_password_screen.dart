import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../widgets/liquid_notification.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/space_particles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  
  // Controllers for form fields
  final _identifierController = TextEditingController();
  final _licenseDigitsController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  int _currentStep = 0;
  String _recoveryMethod = 'email'; // 'email', 'phone', 'license'
  
  late AnimationController _particleController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _licenseDigitsController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _pageController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      AuthResult result;
      
      if (_recoveryMethod == 'license') {
        result = await AuthService.verifyLicenseDigits(
          identifier: _identifierController.text.trim(),
          lastFourDigits: _licenseDigitsController.text.trim(),
        );
      } else {
        result = await AuthService.sendPasswordResetOTP(_identifierController.text.trim());
      }

      if (result.success) {
        LiquidNotification.success(
          context,
          _recoveryMethod == 'license' 
              ? 'License verified! You can now reset your password.'
              : 'OTP sent successfully to your registered contact.',
        );
        
        setState(() {
          _currentStep = 1;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        LiquidNotification.error(context, result.message);
      }
    } catch (e) {
      LiquidNotification.error(context, 'Failed to send OTP. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyOTPAndReset() async {
    if (!_formKey.currentState!.validate()) return;
    if (_newPasswordController.text != _confirmPasswordController.text) {
      LiquidNotification.error(context, 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.resetPassword(
        identifier: _identifierController.text.trim(),
        otp: _recoveryMethod == 'license' ? '123456' : _otpController.text.trim(),
        newPassword: _newPasswordController.text,
      );

      if (result.success) {
        LiquidNotification.success(
          context,
          'Password reset successful! You can now login with your new password.',
        );
        
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        LiquidNotification.error(context, result.message);
      }
    } catch (e) {
      LiquidNotification.error(context, 'Password reset failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      _sendOTP();
    } else {
      _verifyOTPAndReset();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Cosmic background
          const CosmicBackground(),
          
          // Space particles
          SpaceParticles(controller: _particleController),
          
          SafeArea(
            child: Column(
              children: [
                // Header with back button
                _buildHeader(),
                
                // Step indicator
                _buildStepIndicator(),
                
                // Form content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildIdentityVerificationStep(),
                      _buildPasswordResetStep(),
                    ],
                  ),
                ),
                
                // Navigation buttons
                _buildNavigationButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reset Password',
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Step ${_currentStep + 1} of 2',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    )
    .animate()
    .fadeIn()
    .slideY(begin: -0.3, end: 0);
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          for (int i = 0; i < 2; i++) ...[
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: i <= _currentStep 
                      ? const Color(0xFF10B981)
                      : Colors.white.withOpacity(0.2),
                ),
              ),
            ),
            if (i < 1) const SizedBox(width: 8),
          ],
        ],
      ),
    )
    .animate()
    .fadeIn(delay: const Duration(milliseconds: 300))
    .slideY(begin: -0.2, end: 0);
  }

  Widget _buildIdentityVerificationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verify Your Identity',
              style: GoogleFonts.orbitron(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how you want to recover your password',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Recovery method selector
            _buildRecoveryMethodSelector(),
            
            const SizedBox(height: 32),
            
            // Input field based on selected method
            _buildInputField(
              controller: _identifierController,
              label: _recoveryMethod == 'email' 
                  ? 'Email Address'
                  : _recoveryMethod == 'phone' 
                      ? 'Phone Number'
                      : 'Email or Phone',
              hint: _recoveryMethod == 'email' 
                  ? 'Enter your registered email'
                  : _recoveryMethod == 'phone' 
                      ? 'Enter your registered phone number'
                      : 'Enter your email or phone number',
              prefixIcon: _recoveryMethod == 'email' 
                  ? Icons.email
                  : _recoveryMethod == 'phone' 
                      ? Icons.phone
                      : Icons.person,
              keyboardType: _recoveryMethod == 'phone' 
                  ? TextInputType.phone 
                  : TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '${_recoveryMethod == 'email' ? 'Email' : _recoveryMethod == 'phone' ? 'Phone number' : 'Email or phone'} is required';
                }
                return null;
              },
            ),
            
            if (_recoveryMethod == 'license') ...[
              const SizedBox(height: 20),
              _buildInputField(
                controller: _licenseDigitsController,
                label: 'Last 4 Digits of License',
                hint: 'Enter last 4 digits (Demo: 4567)',
                prefixIcon: Icons.card_membership,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Last 4 digits are required';
                  }
                  if (value.length != 4) {
                    return 'Please enter exactly 4 digits';
                  }
                  return null;
                },
              ),
            ],
            
            const SizedBox(height: 32),
            
            _buildInfoBox(),
          ],
        ),
      ),
    )
    .animate()
    .fadeIn(delay: const Duration(milliseconds: 500))
    .slideX(begin: 0.3, end: 0);
  }

  Widget _buildPasswordResetStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create New Password',
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _recoveryMethod == 'license'
                ? 'Your identity has been verified. Create a new password.'
                : 'Enter the OTP sent to you and create a new password',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 32),
          
          if (_recoveryMethod != 'license') ...[
            _buildInputField(
              controller: _otpController,
              label: 'OTP Code',
              hint: 'Enter 6-digit OTP (Demo: any 6 digits)',
              prefixIcon: Icons.security,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'OTP is required';
                }
                if (value.length != 6) {
                  return 'Please enter 6-digit OTP';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
          ],
          
          _buildInputField(
            controller: _newPasswordController,
            label: 'New Password',
            hint: 'Enter your new password',
            prefixIcon: Icons.lock,
            obscureText: !_isPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.white.withOpacity(0.7),
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          _buildInputField(
            controller: _confirmPasswordController,
            label: 'Confirm New Password',
            hint: 'Re-enter your new password',
            prefixIcon: Icons.lock_outline,
            obscureText: !_isConfirmPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.white.withOpacity(0.7),
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recovery Method',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMethodOption('email', 'Email', Icons.email),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMethodOption('phone', 'Phone', Icons.phone),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMethodOption('license', 'License', Icons.card_membership),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodOption(String method, String label, IconData icon) {
    final isSelected = _recoveryMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          _recoveryMethod = method;
          _identifierController.clear();
          _licenseDigitsController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF10B981).withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF10B981)
                : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? const Color(0xFF10B981)
                  : Colors.white.withOpacity(0.7),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? const Color(0xFF10B981)
                    : Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            prefixIcon: Icon(prefixIcon, color: const Color(0xFF10B981)),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF10B981),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Demo Instructions',
                style: TextStyle(
                  color: const Color(0xFF10B981),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _recoveryMethod == 'license'
                ? '• Use existing email/phone: demo@driver.com or +94712345678\n• Enter last 4 digits: 4567'
                : '• Use existing email/phone: demo@driver.com or +94712345678\n• Any 6-digit OTP will work for demo',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: _buildButton(
                'Previous',
                Colors.grey.withOpacity(0.2),
                Colors.white.withOpacity(0.7),
                _previousStep,
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: _currentStep > 0 ? 1 : 2,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return _buildButton(
                  _currentStep == 0 
                      ? (_recoveryMethod == 'license' ? 'Verify License' : 'Send OTP')
                      : 'Reset Password',
                  const Color(0xFF10B981),
                  Colors.white,
                  _isLoading ? null : _nextStep,
                  isLoading: _isLoading,
                  hasGlow: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String text,
    Color backgroundColor,
    Color textColor,
    VoidCallback? onPressed, {
    bool isLoading = false,
    bool hasGlow = false,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: hasGlow ? [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.4 + 0.2 * _glowController.value),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    text,
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
