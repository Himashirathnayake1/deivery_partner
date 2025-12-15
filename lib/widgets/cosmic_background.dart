import 'dart:math';
import 'package:flutter/material.dart';

class CosmicBackground extends StatefulWidget {
  const CosmicBackground({super.key});

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    _generateStars();
  }

  void _generateStars() {
    final random = Random();
    for (int i = 0; i < 200; i++) {
      _stars.add(Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2 + 0.5,
        speed: random.nextDouble() * 0.5 + 0.1,
        opacity: random.nextDouble() * 0.8 + 0.2,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            Color(0xFF1A0033), // Deep purple center
            Color(0xFF0D001A), // Darker purple
            Color(0xFF050008), // Almost black
            Color(0xFF000000), // Pure black
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: StarFieldPainter(_stars, _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class Star {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class StarFieldPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  StarFieldPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final star in stars) {
      // Calculate moving position
      final x = (star.x + animationValue * star.speed) % 1.0;
      final y = star.y;

      // Create twinkling effect
      final twinkle = sin(animationValue * 10 + star.x * 100) * 0.3 + 0.7;
      final opacity = star.opacity * twinkle;

      // Star color with cosmic hues
      final colors = [
        const Color(0xFF10B981),
        const Color(0xFF9C27B0),
        const Color(0xFFFF6B6B),
        Colors.white,
        const Color(0xFF00E5FF),
      ];
      final colorIndex = (star.x * colors.length).floor() % colors.length;
      
      paint.color = colors[colorIndex].withOpacity(opacity);
      
      // Draw star with glow effect
      final center = Offset(x * size.width, y * size.height);
      
      // Outer glow
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(center, star.size * 2, paint);
      
      // Inner bright core
      paint.maskFilter = null;
      canvas.drawCircle(center, star.size, paint);
      
      // Add some bigger stars with cross effect
      if (star.size > 1.5) {
        paint.strokeWidth = 0.5;
        paint.color = colors[colorIndex].withOpacity(opacity * 0.6);
        
        // Horizontal line
        canvas.drawLine(
          Offset(center.dx - 6, center.dy),
          Offset(center.dx + 6, center.dy),
          paint,
        );
        
        // Vertical line
        canvas.drawLine(
          Offset(center.dx, center.dy - 6),
          Offset(center.dx, center.dy + 6),
          paint,
        );
      }
    }

    // Add nebula clouds
    _drawNebula(canvas, size);
  }

  void _drawNebula(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    // Purple nebula
    paint.color = const Color(0xFF10B981).withOpacity(0.1);
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.2),
      100,
      paint,
    );

    // Pink nebula
    paint.color = const Color(0xFFFF6B6B).withOpacity(0.08);
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.8),
      80,
      paint,
    );

    // Blue nebula
    paint.color = const Color(0xFF00E5FF).withOpacity(0.06);
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.6),
      60,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
