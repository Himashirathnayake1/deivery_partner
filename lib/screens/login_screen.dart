import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../widgets/liquid_notification.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/space_particles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

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
    _passwordController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.login(
        _identifierController.text.trim(),
        _passwordController.text,
      );

      if (result.success) {
        LiquidNotification.success(
          context,
          'Welcome back! Logged in successfully.',
        );

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        LiquidNotification.error(context, result.message);
      }
    } catch (e) {
      LiquidNotification.error(context, 'Login failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Logo and title section
                  _buildHeader(),

                  const SizedBox(height: 60),

                  // Login form
                  _buildLoginForm(),

                  const SizedBox(height: 40),

                  // Login button
                  _buildLoginButton(),

                  const SizedBox(height: 24),

                  // Forgot password link
                  _buildForgotPasswordLink(),

                  const SizedBox(height: 40),

                  // Divider
                  _buildDivider(),

                  const SizedBox(height: 40),

                  // Register link
                  _buildRegisterLink(),

                  const SizedBox(height: 20),

                  // Demo credentials info
                  _buildDemoCredentials(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo with glow effect
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withOpacity(0.8),
                    const Color(0xFF10B981).withOpacity(0.4),
                    Colors.transparent,
                  ],
                  stops: [0.3, 0.7, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981)
                        .withOpacity(0.5 + 0.3 * _glowController.value),
                    blurRadius: 30 + 20 * _glowController.value,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.delivery_dining,
                size: 50,
                color: Colors.white,
              ),
            );
          },
        ).animate().scale(
              delay: const Duration(milliseconds: 300),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
            ),

        const SizedBox(height: 24),

        // Title
        Text(
          'Welcome Back',
          style: GoogleFonts.orbitron(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        )
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 600))
            .slideY(begin: 0.5, end: 0),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Sign in to continue your delivery journey',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
            height: 1.4,
          ),
        )
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 800))
            .slideY(begin: 0.5, end: 0),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email/Phone field
          _buildInputField(
            controller: _identifierController,
            label: 'Email or Phone Number',
            hint: 'Enter your email or phone number',
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email or phone number is required';
              }
              return null;
            },
          )
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 1000))
              .slideX(begin: -0.3, end: 0),

          const SizedBox(height: 24),

          // Password field
          _buildInputField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            prefixIcon: Icons.lock_outline,
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
            validator: Validators.validatePassword,
          )
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 1200))
              .slideX(begin: -0.3, end: 0),

          const SizedBox(height: 16),

          // Remember me checkbox
          _buildRememberMeCheckbox()
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 1400))
              .slideX(begin: -0.3, end: 0),
        ],
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

  Widget _buildRememberMeCheckbox() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _rememberMe = !_rememberMe;
            });
          },
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _rememberMe
                    ? const Color(0xFF10B981)
                    : Colors.white.withOpacity(0.5),
                width: 2,
              ),
              color: _rememberMe ? const Color(0xFF10B981) : Colors.transparent,
            ),
            child: _rememberMe
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Remember me',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981)
                    .withOpacity(0.4 + 0.2 * _glowController.value),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLoading ? null : _handleLogin,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Sign In',
                        style: GoogleFonts.orbitron(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 1600))
        .slideY(begin: 0.5, end: 0);
  }

  Widget _buildForgotPasswordLink() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/forgot-password');
      },
      child: Text(
        'Forgot your password?',
        style: TextStyle(
          color: const Color(0xFF10B981),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 1800))
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
        ),
      ],
    ).animate().fadeIn(delay: const Duration(milliseconds: 2000));
  }

  Widget _buildRegisterLink() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/register');
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF10B981).withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            'Create New Account',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF10B981),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 2200))
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildDemoCredentials() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Demo Credentials',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Email: demo@driver.com\nPhone: +94712345678\nPassword: password123',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 2400))
        .slideY(begin: 0.3, end: 0);
  }
}
