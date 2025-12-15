import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _liquidController;
  late AnimationController _floatController;
  int _selectedIndex = 0;

  // Mock data
  final int _completedDeliveries = 147;
  final int _todayDeliveries = 8;
  final double _rating = 4.8;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _liquidController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _liquidController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light background
      body: SafeArea(
        child: Column(
          children: [
            // Header with status toggle
            _buildHeader(),

            // Main content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: Listenable.merge([_liquidController, _floatController]),
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          transform: Matrix4.identity()
            ..translate(0.0, 5.0 * _floatController.value, 0.0),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.5,
              colors: [
                Color.lerp(
                  const Color(0xFF10B981).withOpacity(0.15),
                  const Color(0xFF059669).withOpacity(0.25),
                  _liquidController.value,
                )!,
                Colors.white.withOpacity(0.95),
                const Color(0xFFF0FDF4).withOpacity(0.8),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Color.lerp(
                const Color(0xFF10B981).withOpacity(0.3),
                const Color(0xFF059669).withOpacity(0.5),
                _liquidController.value,
              )!,
              width: 2,
            ),
            boxShadow: [
              // Outer glow effect
              BoxShadow(
                color: Color.lerp(
                  const Color(0xFF10B981).withOpacity(0.4),
                  const Color(0xFF059669).withOpacity(0.6),
                  _liquidController.value,
                )!,
                blurRadius: 25 + (10 * _floatController.value),
                spreadRadius: 2 + (3 * _floatController.value),
                offset: const Offset(0, 0),
              ),
              // Inner depth shadow
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 15,
                spreadRadius: -2,
                offset: const Offset(-2, -2),
              ),
              // Soft bottom shadow
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Floating particles background
              ...List.generate(8, (index) {
                final seed = index * 0.7;
                final xOffset = 50 +
                    (index * 30) +
                    (20 *
                        math.sin(_liquidController.value * 2 * math.pi + seed));
                final yOffset = 20 +
                    (15 *
                        math.cos(
                            _liquidController.value * 1.5 * math.pi + seed));
                return Positioned(
                  left: xOffset,
                  top: yOffset,
                  child: Container(
                    width: 3 + (index % 3),
                    height: 3 + (index % 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF10B981)
                          .withOpacity(0.3 + (0.2 * _floatController.value)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              // Main content
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: const Color(0xFF047857),
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  color:
                                      const Color(0xFF10B981).withOpacity(0.3),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Space Delivery Partner',
                            style: GoogleFonts.orbitron(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF065F46),
                              shadows: [
                                Shadow(
                                  color:
                                      const Color(0xFF10B981).withOpacity(0.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Right side with profile
                      // Animated avatar with space theme
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color.lerp(
                                const Color(0xFF10B981),
                                const Color(0xFF059669),
                                _liquidController.value,
                              )!,
                              const Color(0xFF047857),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.6),
                              blurRadius: 15 + (5 * _floatController.value),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white.withOpacity(0.9),
                          child: Transform.rotate(
                            angle: _liquidController.value * 2 * math.pi * 0.1,
                            child: Icon(
                              Icons.rocket_launch,
                              size: 28,
                              color: Color.lerp(
                                const Color(0xFF10B981),
                                const Color(0xFF059669),
                                _floatController.value,
                              )!,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    )
        .animate()
        .slideY(
            begin: -0.3, end: 0, duration: const Duration(milliseconds: 1200))
        .fadeIn(duration: const Duration(milliseconds: 800))
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          _buildStatsGrid(),

          const SizedBox(height: 32),

          // Quick Actions
          _buildQuickActions(),

          const SizedBox(height: 32),

          // Recent Activity
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Completed',
                '$_completedDeliveries',
                Iconsax.task_square,
                const Color(0xFF10B981),
                0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Today\'s Runs',
                '$_todayDeliveries',
                Iconsax.flash_circle,
                const Color(0xFFEF4444),
                100,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
              flex: 2,
              child: _buildStatCard(
                'Rating',
                '$_rating ⭐',
                Iconsax.star,
                const Color(0xFFF59E0B),
                200,
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, int delay) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF475569).withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 28,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
        .fadeIn(duration: const Duration(milliseconds: 600));
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                'Find Orders',
                Iconsax.search_normal,
                const Color(0xFF3B82F6),
                () {},
              ),
              _buildActionButton(
                'Navigation',
                Iconsax.location,
                const Color(0xFF10B981),
                () {},
              ),
              _buildActionButton(
                'Earnings',
                Iconsax.chart_2,
                const Color(0xFFF59E0B),
                () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF475569).withOpacity(0.08),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 25,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),
          _buildActivityItem('Delivery Completed Successfully', '2 hrs ago',
              Iconsax.tick_circle, const Color(0xFF10B981)),
          _buildActivityItem('New Order Pickup Assigned', '4 hrs ago',
              Iconsax.box, const Color(0xFF3B82F6)),
          _buildActivityItem('Earned Rs. 250 Performance Bonus', '6 hrs ago',
              Iconsax.coin, const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      String title, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF475569).withOpacity(0.06),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          // Strong green outer glow
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.8),
            blurRadius: 50,
            spreadRadius: 8,
            offset: const Offset(0, 0),
          ),
          // Medium green glow
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.6),
            blurRadius: 30,
            spreadRadius: 4,
            offset: const Offset(0, 0),
          ),
          // Inner green glow
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 0),
          ),
          // Subtle professional shadow
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.08),
            blurRadius: 25,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.6),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Iconsax.home, 'Home', 0),
          _buildNavItem(Iconsax.box, 'Orders', 1),
          _buildNavItem(Iconsax.profile_circle, 'Profile', 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3B82F6).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFF64748B),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
