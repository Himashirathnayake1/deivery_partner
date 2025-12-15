import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/space_particles.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/floating_orbs.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _startAnimation();
  }

  void _startAnimation() async {
    await _mainController.forward();
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Cosmic background with moving stars
          const CosmicBackground(),

          // Space particles
          SpaceParticles(controller: _particleController),

          // Floating orbs
          FloatingOrbs(controller: _particleController),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with supernatural glow effect
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF10B981).withOpacity(0.8),
                        const Color(0xFF059669).withOpacity(0.6),
                        const Color(0xFF047857).withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color.lerp(
                              const Color(0xFF10B981),
                              const Color(0xFF059669),
                              _pulseController.value,
                            )!,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.delivery_dining,
                          size: 80,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                )
                    .animate()
                    .scale(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: const Duration(milliseconds: 800))
                    .then()
                    .shimmer(
                      duration: const Duration(milliseconds: 2000),
                      color: const Color(0xFF10B981),
                    ),

                const SizedBox(height: 50),

                // App title with animated text
                SizedBox(
                  height: 80,
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'DELIVERY PARTNER',
                        textStyle: GoogleFonts.orbitron(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: const Color(0xFF10B981).withOpacity(0.8),
                              blurRadius: 10,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    totalRepeatCount: 1,
                  ),
                )
                    .animate(delay: const Duration(milliseconds: 1000))
                    .fadeIn(duration: const Duration(milliseconds: 800))
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 20),

                // Subtitle
                Text(
                  'Your Journey to the Stars Begins',
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    color: Colors.white70,
                    letterSpacing: 2,
                  ),
                )
                    .animate(delay: const Duration(milliseconds: 2000))
                    .fadeIn(duration: const Duration(milliseconds: 1000))
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 80),

                // Loading indicator with supernatural effects
                SizedBox(
                  width: 200,
                  child: Column(
                    children: [
                      // Cosmic loading bar
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF10B981),
                              Color(0xFF059669),
                              Color(0xFF047857),
                            ],
                          ),
                        ),
                        child: AnimatedBuilder(
                          animation: _mainController,
                          builder: (context, child) {
                            return LinearProgressIndicator(
                              value: _mainController.value,
                              backgroundColor: Colors.white10,
                              valueColor: AlwaysStoppedAnimation(
                                Color.lerp(
                                  const Color(0xFF10B981),
                                  const Color(0xFF059669),
                                  _mainController.value,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Loading text
                      AnimatedBuilder(
                        animation: _mainController,
                        builder: (context, child) {
                          final loadingTexts = [
                            'Initializing Quantum Drive...',
                            'Connecting to Cosmic Network...',
                            'Activating Delivery Matrix...',
                            'Ready for Interdimensional Delivery!',
                          ];
                          final index = (_mainController.value * 4).floor();
                          final text = index < loadingTexts.length 
                              ? loadingTexts[index] 
                              : loadingTexts.last;
                          
                          return Text(
                            text,
                            style: GoogleFonts.orbitron(
                              fontSize: 12,
                              color: Colors.white60,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ],
                  ),
                )
                    .animate(delay: const Duration(milliseconds: 2500))
                    .fadeIn(duration: const Duration(milliseconds: 800))
                    .slideY(begin: 0.3, end: 0),
              ],
            ),
          ),

          // Company branding at bottom
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Powered by ',
                      style: GoogleFonts.orbitron(
                        fontSize: 9,
                        color: Colors.white.withOpacity(0.5),
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Text(
                          'Pegas (Pvt) Ltd',
                          style: GoogleFonts.orbitron(
                            fontSize: 9,
                            fontWeight: FontWeight.w400,
                            color: Color.lerp(
                              Colors.white.withOpacity(0.6),
                              const Color(0xFF10B981).withOpacity(0.8),
                              _pulseController.value,
                            ),
                            letterSpacing: 0.8,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          )
              .animate(delay: const Duration(milliseconds: 3000))
              .fadeIn(duration: const Duration(milliseconds: 1200))
              .slideY(begin: 0.5, end: 0)
              .then()
              .shimmer(
                duration: const Duration(milliseconds: 2000),
                color: const Color(0xFF10B981),
              ),

          // Mystical border effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.all(20),
            ),
          )
              .animate(delay: const Duration(milliseconds: 500))
              .fadeIn(duration: const Duration(milliseconds: 1500))
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
        ],
      ),
    );
  }
}
