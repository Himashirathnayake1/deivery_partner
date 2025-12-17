import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../models/delivery_order.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/liquid_notification.dart';

class OrderProcessScreen extends StatefulWidget {
  final DeliveryOrder order;
  final Function(double) onOrderCompleted;

  const OrderProcessScreen({
    super.key,
    required this.order,
    required this.onOrderCompleted,
  });

  @override
  State<OrderProcessScreen> createState() => _OrderProcessScreenState();
}

class _OrderProcessScreenState extends State<OrderProcessScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  int _currentStep = 0;
  Timer? _progressTimer;
  bool _isCompleted = false;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Order Accepted',
      'subtitle': 'Navigating to pickup location',
      'icon': Icons.check_circle,
      'color': Color(0xFF00E676),
      'duration': 3,
    },
    {
      'title': 'Heading to Pickup',
      'subtitle': 'En route to restaurant/sender',
      'icon': Icons.directions_walk,
      'color': Color(0xFF10B981),
      'duration': 8,
    },
    {
      'title': 'At Pickup Location',
      'subtitle': 'Collecting the order',
      'icon': Icons.location_on,
      'color': Color(0xFFFF6B6B),
      'duration': 5,
    },
    {
      'title': 'Order Picked Up',
      'subtitle': 'Heading to delivery location',
      'icon': Icons.local_shipping,
      'color': Color(0xFFFFB74D),
      'duration': 10,
    },
    {
      'title': 'Delivered Successfully',
      'subtitle': 'Order completed',
      'icon': Icons.task_alt,
      'color': Color(0xFF00E676),
      'duration': 2,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _startOrderProcess();
  }

  void _startOrderProcess() {
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentStep < _steps.length - 1) {
        if (timer.tick >= _getStepEndTime(_currentStep)) {
          setState(() {
            _currentStep++;
          });
          
          // Show liquid notification for each step
          LiquidNotification.success(
            context,
            _steps[_currentStep]['subtitle'],
          );
          
          if (_currentStep == _steps.length - 1) {
            // Order completed
            Timer(const Duration(seconds: 2), () {
              setState(() {
                _isCompleted = true;
              });
              widget.onOrderCompleted(widget.order.totalAmount ?? 0);
              
              Timer(const Duration(seconds: 3), () {
                Navigator.pop(context);
              });
            });
          }
        }
      }
    });
  }

  int _getStepEndTime(int stepIndex) {
    int totalTime = 0;
    for (int i = 0; i <= stepIndex; i++) {
      totalTime += _steps[i]['duration'] as int;
    }
    return totalTime;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressTimer?.cancel();
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
                
                // Order Progress
                Expanded(
                  child: _buildOrderProgress(),
                ),
                
                // Completion Screen
                if (_isCompleted) _buildCompletionOverlay(),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_shipping,
                  color: Color(0xFF00E676),
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${widget.order.id.substring(4, 10)}',
                      style: GoogleFonts.orbitron(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Customer: ${widget.order.customerName}',
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E676), Color(0xFF00C853)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Rs. ${widget.order.totalAmount?.toInt() ?? 0}',
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 15),
          
          // Customer Contact
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone, color: Color(0xFF10B981), size: 20),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    final Uri launchUri = Uri(
                      scheme: 'tel',
                      path: widget.order.customerPhone,
                    );
                    if (await canLaunchUrl(launchUri)) {
                      await launchUrl(launchUri);
                    } else {
                      LiquidNotification.error(context, 'Could not launch dialer');
                    }
                  },
                  child: Text(
                    widget.order.customerPhone,
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.call, size: 16),
                  label: Text(
                    'Call',
                    style: GoogleFonts.orbitron(fontSize: 12),
                  ),
                  onPressed: () async {
                    final Uri launchUri = Uri(
                      scheme: 'tel',
                      path: widget.order.customerPhone,
                    );
                    if (await canLaunchUrl(launchUri)) {
                      await launchUrl(launchUri);
                    } else {
                      LiquidNotification.error(context, 'Could not launch dialer');
                    }
                  },
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

  Widget _buildOrderProgress() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress Steps
          Expanded(
            child: ListView.builder(
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final step = _steps[index];
                final isActive = index == _currentStep;
                final isCompleted = index < _currentStep;
                final isUpcoming = index > _currentStep;

                return _buildProgressStep(
                  step: step,
                  index: index,
                  isActive: isActive,
                  isCompleted: isCompleted,
                  isUpcoming: isUpcoming,
                );
              },
            ),
          ),
          
          // Order Details
          _buildOrderDetails(),
        ],
      ),
    );
  }

  Widget _buildProgressStep({
    required Map<String, dynamic> step,
    required int index,
    required bool isActive,
    required bool isCompleted,
    required bool isUpcoming,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          // Step Indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted 
                  ? const Color(0xFF00E676)
                  : isActive 
                      ? step['color']
                      : Colors.grey.withOpacity(0.3),
              border: Border.all(
                color: isActive 
                    ? step['color']
                    : isCompleted 
                        ? const Color(0xFF00E676)
                        : Colors.grey.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: isActive ? [
                BoxShadow(
                  color: step['color'].withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ] : [],
            ),
            child: isActive 
                ? AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseController.value * 0.2),
                        child: Icon(
                          step['icon'],
                          color: Colors.white,
                          size: 28,
                        ),
                      );
                    },
                  )
                : Icon(
                    isCompleted ? Icons.check : step['icon'],
                    color: Colors.white,
                    size: 28,
                  ),
          ),
          
          const SizedBox(width: 20),
          
          // Step Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isActive 
                    ? step['color'].withOpacity(0.1)
                    : const Color(0xFF1A1A1A).withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive 
                      ? step['color'].withOpacity(0.5)
                      : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step['title'],
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    step['subtitle'],
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      color: isActive ? step['color'] : Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 200))
      .slideX(begin: -0.3, end: 0)
      .fadeIn();
  }

  Widget _buildOrderDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A1A).withOpacity(0.8),
            const Color(0xFF2A2A2A).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Details',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF10B981), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'From: ${widget.order.pickupAddress}',
                  style: GoogleFonts.orbitron(fontSize: 12, color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.flag, color: Color(0xFF00E676), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'To: ${widget.order.deliveryAddress}',
                  style: GoogleFonts.orbitron(fontSize: 12, color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Order Support Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                // Support Agent Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.support_agent, color: Color(0xFF10B981), size: 20),
                ),
                const SizedBox(width: 12),
                // Order Support Text & Phone Number
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Support',
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '0755077070',
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Call Icon Button - Separate & Clearly Visible
                GestureDetector(
                  onTap: () async {
                    final Uri launchUri = Uri(
                      scheme: 'tel',
                      path: '0755077070',
                    );
                    if (await canLaunchUrl(launchUri)) {
                      await launchUrl(launchUri);
                    } else {
                      LiquidNotification.error(context, 'Could not launch dialer');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF10B981), Color(0xFF00C853)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.call,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDetailItem('Distance', '${widget.order.distance} km', Icons.straighten),
              _buildDetailItem('Earnings', 'Rs. ${widget.order.totalAmount?.toInt() ?? 0}', Icons.monetization_on),
              _buildDetailItem('Rating', '${widget.order.rating.toStringAsFixed(1)}★', Icons.star),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF10B981), size: 20),
        const SizedBox(height: 5),
        Text(
          label,
          style: GoogleFonts.orbitron(fontSize: 10, color: Colors.white60),
        ),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(30),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF00E676),
                Color(0xFF00C853),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E676).withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.task_alt,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              Text(
                'Order Completed!',
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Rs. ${widget.order.totalAmount?.toInt() ?? 0} earned',
                style: GoogleFonts.orbitron(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Money added to your wallet',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .scale(begin: const Offset(0, 0), end: const Offset(1, 1))
      .fadeIn(duration: const Duration(milliseconds: 800));
  }
}
