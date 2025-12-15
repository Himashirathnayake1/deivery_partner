import 'dart:math';
import 'package:flutter/material.dart';

class SpaceParticles extends StatelessWidget {
  final AnimationController controller;

  const SpaceParticles({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Generate floating particles
    for (int i = 0; i < 50; i++) {
      final seed = i * 123.456;

      // Calculate particle position with floating movement
      final baseX = (seed % size.width);
      final baseY = (seed * 2.5) % size.height;

      final floatX = baseX + sin(animationValue * 2 * pi + seed) * 30;
      final floatY = baseY + cos(animationValue * 1.5 * pi + seed) * 20;

      // Particle opacity with pulsing effect
      final pulse = sin(animationValue * 4 * pi + seed) * 0.3 + 0.7;
      final opacity = (0.3 + (seed % 0.5)) * pulse;

      // Particle size variation
      final particleSize = 1 + (seed % 3);

      // Particle color - cosmic themed
      final colorSeed = (seed * 7) % 5;
      Color particleColor;
      switch (colorSeed.toInt()) {
        case 0:
          particleColor = const Color(0xFF10B981);
          break;
        case 1:
          particleColor = const Color(0xFF9C27B0);
          break;
        case 2:
          particleColor = const Color(0xFF10B981);
          break;
        case 3:
          particleColor = const Color(0xFF00E5FF);
          break;
        default:
          particleColor = Colors.white;
      }

      paint.color = particleColor.withOpacity(opacity);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

      canvas.drawCircle(
        Offset(floatX, floatY),
        particleSize,
        paint,
      );
    }

    // Add energy streams
    _drawEnergyStreams(canvas, size, paint);
  }

  void _drawEnergyStreams(Canvas canvas, Size size, Paint paint) {
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      final path = Path();
      final startY = size.height * 0.2 * (i + 1);

      path.moveTo(-50, startY);

      for (double x = -50; x <= size.width + 50; x += 10) {
        final waveY = startY + sin((x / 100 + animationValue * 2 + i)) * 20;
        path.lineTo(x, waveY);
      }

      final gradient = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF10B981).withOpacity(0.3),
          const Color(0xFF9C27B0).withOpacity(0.3),
          Colors.transparent,
        ],
      );

      paint.shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
