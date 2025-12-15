import 'dart:math';
import 'package:flutter/material.dart';

class FloatingOrbs extends StatelessWidget {
  final AnimationController controller;

  const FloatingOrbs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: OrbPainter(controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class OrbPainter extends CustomPainter {
  final double animationValue;

  OrbPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw mystical floating orbs
    _drawOrb(
      canvas,
      size,
      Offset(
        size.width * 0.1 + sin(animationValue * 2 * pi) * 50,
        size.height * 0.2 + cos(animationValue * 1.5 * pi) * 30,
      ),
      30,
      const Color(0xFF10B981),
    );

    _drawOrb(
      canvas,
      size,
      Offset(
        size.width * 0.9 + sin(animationValue * 1.5 * pi + pi) * 40,
        size.height * 0.8 + cos(animationValue * 2 * pi + pi) * 25,
      ),
      25,
      const Color(0xFFFF6B6B),
    );

    _drawOrb(
      canvas,
      size,
      Offset(
        size.width * 0.8 + sin(animationValue * 1.8 * pi + pi/2) * 35,
        size.height * 0.3 + cos(animationValue * 1.2 * pi + pi/2) * 40,
      ),
      20,
      const Color(0xFF00E5FF),
    );

    _drawOrb(
      canvas,
      size,
      Offset(
        size.width * 0.2 + sin(animationValue * 1.3 * pi + pi/4) * 30,
        size.height * 0.7 + cos(animationValue * 1.8 * pi + pi/4) * 35,
      ),
      18,
      const Color(0xFF9C27B0),
    );
  }

  void _drawOrb(Canvas canvas, Size size, Offset center, double radius, Color color) {
    final paint = Paint();

    // Outer glow with multiple layers
    for (int i = 5; i >= 0; i--) {
      final glowRadius = radius + (i * 8);
      final opacity = (0.1 - i * 0.015) * (sin(animationValue * 4 * pi) * 0.3 + 0.7);
      
      paint.color = color.withOpacity(opacity);
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, i * 2.0);
      
      canvas.drawCircle(center, glowRadius, paint);
    }

    // Inner orb with gradient
    paint.maskFilter = null;
    paint.shader = RadialGradient(
      colors: [
        color.withOpacity(0.8),
        color.withOpacity(0.4),
        color.withOpacity(0.1),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 0.8, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);

    // Bright center core
    paint.shader = null;
    paint.color = Colors.white.withOpacity(0.9);
    canvas.drawCircle(center, radius * 0.3, paint);

    // Add sparkle effects around the orb
    _drawSparkles(canvas, center, radius, color);
  }

  void _drawSparkles(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 1;

    final sparkleCount = 6;
    final sparkleRadius = radius + 15;

    for (int i = 0; i < sparkleCount; i++) {
      final angle = (i / sparkleCount) * 2 * pi + animationValue * 2 * pi;
      final sparkleCenter = Offset(
        center.dx + cos(angle) * sparkleRadius,
        center.dy + sin(angle) * sparkleRadius,
      );

      // Create cross-shaped sparkles
      final sparkleSize = 4 + sin(animationValue * 6 * pi + i) * 2;
      
      // Horizontal line
      canvas.drawLine(
        Offset(sparkleCenter.dx - sparkleSize, sparkleCenter.dy),
        Offset(sparkleCenter.dx + sparkleSize, sparkleCenter.dy),
        paint,
      );
      
      // Vertical line
      canvas.drawLine(
        Offset(sparkleCenter.dx, sparkleCenter.dy - sparkleSize),
        Offset(sparkleCenter.dx, sparkleCenter.dy + sparkleSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
