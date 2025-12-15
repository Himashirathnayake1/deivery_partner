import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/driver_user.dart';
import '../widgets/liquid_notification.dart';
import '../widgets/cosmic_background.dart';

class ProfileScreen extends StatefulWidget {
  final DriverUser? user;
  
  const ProfileScreen({super.key, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late DriverUser currentUser;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for editing
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    
    currentUser = widget.user ?? DriverUser(
      id: '1',
      name: 'Demo Driver',
      email: 'demo@driver.com',
      phoneNumber: '+94712345678',
      address: '123 Main Street, Colombo 07',
      nicNumber: '199512345678',
      drivingLicenseNumber: 'B1234567',
      vehicleType: VehicleType.bike,
      isVerified: true,
      createdAt: DateTime(2023, 1, 1),
    );
    
    // Initialize controllers
    _nameController = TextEditingController(text: currentUser.name);
    _emailController = TextEditingController(text: currentUser.email);
    _phoneController = TextEditingController(text: currentUser.phoneNumber);
    _addressController = TextEditingController(text: currentUser.address);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
    
    if (!_isEditing) {
      _saveProfile();
    }
  }
  
  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        currentUser = DriverUser(
          id: currentUser.id,
          name: _nameController.text,
          email: _emailController.text,
          phoneNumber: _phoneController.text,
          address: _addressController.text,
          nicNumber: currentUser.nicNumber,
          drivingLicenseNumber: currentUser.drivingLicenseNumber,
          vehicleType: currentUser.vehicleType,
          isVerified: currentUser.isVerified,
          createdAt: currentUser.createdAt,
        );
      });
      
      LiquidNotification.success(context, 'Profile updated successfully!');
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Logout',
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to logout from your account?',
          style: GoogleFonts.orbitron(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.orbitron(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Logout',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      LiquidNotification.info(context, 'Logging out...');
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Optimized cosmic background
          Opacity(
            opacity: 0.3,
            child: const CosmicBackground(),
          ),
          
          SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  
                  // Profile content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Profile picture and basic info
                          _buildProfileSection(),
                          
                          const SizedBox(height: 20),
                          
                          // Statistics cards
                          _buildStatsCards(),
                          
                          const SizedBox(height: 20),
                          
                          // Profile details
                          _buildProfileDetails(),
                          
                          const SizedBox(height: 20),
                          
                          // Vehicle info
                          _buildVehicleInfo(),
                          
                          const SizedBox(height: 20),
                          
                          // Action buttons
                          _buildActionButtons(),
                          
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A1A).withOpacity(0.9),
            const Color(0xFF2A2A2A).withOpacity(0.7),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF10B981),
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(width: 15),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Driver Profile',
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Manage your account & settings',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          GestureDetector(
            onTap: _toggleEdit,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isEditing ? const Color(0xFF00E676).withOpacity(0.2) : const Color(0xFF10B981).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isEditing ? const Color(0xFF00E676).withOpacity(0.5) : const Color(0xFF10B981).withOpacity(0.3),
                ),
              ),
              child: Icon(
                _isEditing ? Icons.save : Icons.edit,
                color: _isEditing ? const Color(0xFF00E676) : const Color(0xFF10B981),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    ).animate()
      .slideY(begin: -0.3, end: 0, duration: const Duration(milliseconds: 800))
      .fadeIn(duration: const Duration(milliseconds: 600));
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        // Profile picture with glow effect
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withOpacity(0.8),
                    const Color(0xFF10B981).withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.4 + 0.2 * _animationController.value),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      currentUser.name.split(' ').map((e) => e[0]).take(2).join().toUpperCase(),
                      style: GoogleFonts.orbitron(
                        fontSize: 28,
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
        .scale(
          delay: const Duration(milliseconds: 300),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
        ),
        
        const SizedBox(height: 16),
        
        // Name and verification status
        Text(
          currentUser.name,
          style: GoogleFonts.orbitron(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 600))
        .slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 8),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: currentUser.isVerified ? const Color(0xFF00E676) : const Color(0xFFFF9800),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                currentUser.isVerified ? Icons.verified : Icons.pending,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                currentUser.isVerified ? 'Verified Driver' : 'Pending Verification',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 800))
        .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildProfileDetails() {
    return Column(
      children: [
        _buildDetailCard(
          'Personal Information',
          [
            _buildDetailRow('Full Name', currentUser.name, Icons.person),
            _buildDetailRow('Email', currentUser.email, Icons.email),
            _buildDetailRow('Phone', currentUser.phoneNumber, Icons.phone),
            _buildDetailRow('Address', currentUser.address, Icons.location_on),
            _buildDetailRow('NIC Number', currentUser.nicNumber, Icons.credit_card),
          ],
        ),
        
        const SizedBox(height: 20),
        
        _buildDetailCard(
          'Vehicle Information',
          [
            _buildDetailRow('License Number', currentUser.drivingLicenseNumber, Icons.card_membership),
            _buildDetailRow('Vehicle Type', '${currentUser.vehicleType.icon} ${currentUser.vehicleType.displayName}', Icons.directions_car),
            _buildDetailRow('Registration Date', '${currentUser.createdAt.day}/${currentUser.createdAt.month}/${currentUser.createdAt.year}', Icons.calendar_today),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    )
    .animate()
    .fadeIn(delay: const Duration(milliseconds: 1000))
    .slideY(begin: 0.3, end: 0);
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: const Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Edit Profile Button
        _buildActionButton(
          'Edit Profile',
          Icons.edit,
          const Color(0xFF10B981),
          () {
            LiquidNotification.info(context, 'Edit profile functionality coming soon!');
          },
        ),
        
        const SizedBox(height: 16),
        
        // Settings Button
        _buildActionButton(
          'Settings',
          Icons.settings,
          const Color(0xFF00E676),
          () {
            LiquidNotification.info(context, 'Settings functionality coming soon!');
          },
        ),
        
        const SizedBox(height: 16),
        
        // Help & Support Button
        _buildActionButton(
          'Help & Support',
          Icons.help,
          const Color(0xFFFF9800),
          () {
            LiquidNotification.info(context, 'Help & Support coming soon!');
          },
        ),
        
        const SizedBox(height: 32),
        
        // Logout Button
        _buildActionButton(
          'Logout',
          Icons.logout,
          const Color(0xFFFF6B6B),
          _handleLogout,
        ),
      ],
    )
    .animate()
    .fadeIn(delay: const Duration(milliseconds: 1200))
    .slideY(begin: 0.3, end: 0);
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total Earnings', 'Rs. 12,450', Icons.monetization_on, const Color(0xFF10B981))),
        const SizedBox(width: 15),
        Expanded(child: _buildStatCard('Completed', '147', Icons.task_alt, const Color(0xFF00E676))),
        const SizedBox(width: 15),
        Expanded(child: _buildStatCard('Rating', '4.8⭐', Icons.star, const Color(0xFFFFB74D))),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.orbitron(
              fontSize: 10,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 1000))
      .scale(begin: const Offset(0.8, 0.8))
      .fadeIn();
  }

  Widget _buildVehicleInfo() {
    return _buildDetailCard(
      'Vehicle Information',
      [
        _buildDetailRow('License Number', currentUser.drivingLicenseNumber, Icons.card_membership),
        _buildDetailRow('Vehicle Type', 'Three Wheel', Icons.directions_car),
        _buildDetailRow('Registration Date', '${currentUser.createdAt.day}/${currentUser.createdAt.month}/${currentUser.createdAt.year}', Icons.calendar_today),
      ],
    );
  }

}
