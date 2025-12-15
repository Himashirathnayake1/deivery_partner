import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/liquid_notification.dart';

class EarningsScreen extends StatefulWidget {
  final double? currentBalance;
  
  const EarningsScreen({super.key, this.currentBalance});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;

  // Wallet data
  late double _currentBalance;
  final double _todayEarnings = 320.50;
  final double _weeklyEarnings = 1850.25;
  final double _monthlyEarnings = 7420.80;
  final int _completedTrips = 147;
  final double _averageRating = 4.8;

  // Mock completed orders
  final List<Map<String, dynamic>> _completedOrders = [
    {
      'orderId': '#ORD001',
      'customerName': 'John Silva',
      'restaurant': 'KFC Colombo',
      'amount': 125.50,
      'date': 'Nov 29, 2:30 PM',
      'distance': '3.2 km',
      'status': 'Completed',
    },
    {
      'orderId': '#ORD002',
      'customerName': 'Sarah Fernando',
      'restaurant': 'Pizza Hut',
      'amount': 89.75,
      'date': 'Nov 29, 1:15 PM',
      'distance': '2.8 km',
      'status': 'Completed',
    },
    {
      'orderId': '#ORD003',
      'customerName': 'Mike Perera',
      'restaurant': 'McDonald\'s',
      'amount': 105.25,
      'date': 'Nov 29, 11:45 AM',
      'distance': '4.1 km',
      'status': 'Completed',
    },
    {
      'orderId': '#ORD004',
      'customerName': 'Lisa Jayawardena',
      'restaurant': 'Subway',
      'amount': 67.80,
      'date': 'Nov 28, 6:20 PM',
      'distance': '2.1 km',
      'status': 'Completed',
    },
    {
      'orderId': '#ORD005',
      'customerName': 'David Kumar',
      'restaurant': 'Domino\'s Pizza',
      'amount': 145.90,
      'date': 'Nov 28, 4:10 PM',
      'distance': '5.3 km',
      'status': 'Completed',
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentBalance = widget.currentBalance ?? 2450.75;
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Cosmic background
          Opacity(
            opacity: 0.3,
            child: const CosmicBackground(),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                // Content
                Expanded(
                  child: _buildContent(),
                ),
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
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Earnings & Wallet',
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Manage your earnings & withdrawals',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .slideY(begin: -0.3, end: 0, duration: const Duration(milliseconds: 800))
      .fadeIn(duration: const Duration(milliseconds: 600));
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wallet Balance Card
          _buildWalletCard(),
          
          const SizedBox(height: 20),
          
          // Earnings Summary
          _buildEarningsSummary(),
          
          const SizedBox(height: 20),
          
          // Quick Actions
          _buildQuickActions(),
          
          const SizedBox(height: 30),
          
          // Completed Orders History
          _buildOrdersHistory(),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF10B981),
            Color(0xFF9C27B0),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Balance',
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: Colors.white70,
                    child: Text(
                      'Rs. ${_currentBalance.toStringAsFixed(2)}',
                      style: GoogleFonts.orbitron(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.1),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Earnings',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'Rs. ${_todayEarnings.toStringAsFixed(2)}',
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Completed Trips',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '$_completedTrips',
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: const Duration(milliseconds: 200))
      .slideX(begin: -0.3, end: 0)
      .fadeIn();
  }

  Widget _buildEarningsSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earnings Summary',
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildEarningStat('Weekly', 'Rs. $_weeklyEarnings', const Color(0xFF00E676))),
              Expanded(child: _buildEarningStat('Monthly', 'Rs. $_monthlyEarnings', const Color(0xFFFF6B6B))),
              Expanded(child: _buildEarningStat('Rating', '$_averageRating ⭐', const Color(0xFFFFB74D))),
            ],
          ),
        ],
      ),
    ).animate(delay: const Duration(milliseconds: 400))
      .slideX(begin: 0.3, end: 0)
      .fadeIn();
  }

  Widget _buildEarningStat(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.orbitron(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Withdraw Money',
            Icons.money_off,
            const Color(0xFF00E676),
            _showWithdrawDialog,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildActionButton(
            'Transaction History',
            Icons.history,
            const Color(0xFF10B981),
            _showTransactionHistory,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.3),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: const Duration(milliseconds: 600))
      .scale(begin: const Offset(0.8, 0.8))
      .fadeIn();
  }

  Widget _buildOrdersHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Completed Orders',
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _completedOrders.length,
          itemBuilder: (context, index) {
            final order = _completedOrders[index];
            return _buildOrderItem(order, index);
          },
        ),
      ],
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF00E676).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF00E676),
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order['orderId'],
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    Text(
                      'Rs. ${order['amount']}',
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00E676),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '${order['customerName']} • ${order['restaurant']}',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: Colors.white60,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${order['distance']} • ${order['date']}',
                      style: GoogleFonts.orbitron(
                        fontSize: 11,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 800 + (index * 100)))
      .slideX(begin: 0.3, end: 0)
      .fadeIn();
  }

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Withdraw Money',
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Available Balance: Rs. $_currentBalance',
              style: GoogleFonts.orbitron(
                fontSize: 16,
                color: const Color(0xFF00E676),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              style: GoogleFonts.orbitron(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Amount to withdraw',
                labelStyle: GoogleFonts.orbitron(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF10B981)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF10B981)),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.orbitron(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              LiquidNotification.success(
                context,
                'Withdrawal request submitted! Funds will be transferred within 24 hours.',
              );
            },
            child: Text(
              'Withdraw',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionHistory() {
    LiquidNotification.info(
      context,
      'Transaction history feature will be available soon!',
    );
  }
}
