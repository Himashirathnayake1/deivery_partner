import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../models/delivery_order.dart';

class TimedOrderCard extends StatefulWidget {
  final DeliveryOrder order;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onTimeout;

  const TimedOrderCard({
    super.key,
    required this.order,
    required this.onAccept,
    required this.onReject,
    required this.onTimeout,
  });

  @override
  State<TimedOrderCard> createState() => _TimedOrderCardState();
}

class _TimedOrderCardState extends State<TimedOrderCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _timerController;
  late AnimationController _urgencyController;
  Timer? _countdownTimer;
  int _remainingSeconds = 120; // 2 minutes
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _timerController = AnimationController(
      duration: const Duration(seconds: 120), // 2 minutes
      vsync: this,
    );

    _urgencyController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _startCountdown();
    _timerController.forward();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds--;

          // Start urgency animation when less than 30 seconds
          if (_remainingSeconds <= 30 && !_urgencyController.isAnimating) {
            _urgencyController.repeat(reverse: true);
          }

          if (_remainingSeconds <= 0) {
            _isExpired = true;
            timer.cancel();
            widget.onTimeout();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timerController.dispose();
    _urgencyController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isExpired) {
      return _buildExpiredCard();
    }

    return _buildActiveCard();
  }

  Widget _buildActiveCard() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final isUrgent = _remainingSeconds <= 30;

    return AnimatedBuilder(
      animation: _urgencyController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isUrgent ? Colors.red : const Color(0xFF10B981))
                    .withOpacity(isUrgent
                        ? 0.4 + (_urgencyController.value * 0.3)
                        : 0.3),
                blurRadius: 20,
                spreadRadius: 3,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A1A1A).withOpacity(0.95),
                    const Color(0xFF2A2A2A).withOpacity(0.95),
                  ],
                ),
                border: Border.all(
                  color: (isUrgent ? Colors.red : const Color(0xFF10B981))
                      .withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  // Timer Progress Bar
                  AnimatedBuilder(
                    animation: _timerController,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: 1.0 - _timerController.value,
                        backgroundColor: Colors.grey.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isUrgent ? Colors.red : const Color(0xFF10B981),
                        ),
                        minHeight: 4,
                      );
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with timer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: widget.order.isPriority
                                        ? const Color(0xFFFF6B6B)
                                            .withOpacity(0.2)
                                        : const Color(0xFF10B981)
                                            .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    widget.order.orderType == OrderType.food
                                        ? Icons.restaurant
                                        : widget.order.orderType ==
                                                OrderType.delivery
                                            ? Icons.local_shipping
                                            : Icons.directions_car,
                                    color: widget.order.isPriority
                                        ? const Color(0xFFFF6B6B)
                                        : const Color(0xFF10B981),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Order #${widget.order.id.substring(4, 10)}',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                if (widget.order.isPriority) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF6B6B),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'RUSH',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isUrgent
                                    ? Colors.red.withOpacity(0.2)
                                    : const Color(0xFF00E676).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: isUrgent
                                      ? Colors.red
                                      : const Color(0xFF00E676),
                                ),
                              ),
                              child: Text(
                                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                                style: GoogleFonts.orbitron(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isUrgent
                                      ? Colors.red
                                      : const Color(0xFF00E676),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // Customer Info
                        Row(
                          children: [
                            const Icon(Icons.person,
                                color: Colors.white70, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              widget.order.customerName,
                              style: GoogleFonts.orbitron(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        if (widget.order.restaurantName != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.restaurant,
                                  color: Colors.orange, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                widget.order.restaurantName!,
                                style: GoogleFonts.orbitron(
                                  fontSize: 14,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 15),

                        // Location Details
                        _buildLocationInfo('Pickup', widget.order.pickupAddress,
                            Icons.location_on, const Color(0xFF10B981)),
                        const SizedBox(height: 10),
                        _buildLocationInfo(
                            'Drop-off',
                            widget.order.deliveryAddress,
                            Icons.flag,
                            const Color(0xFF00E676)),

                        const SizedBox(height: 15),

                        // Order Details
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildDetailChip('${widget.order.distance} km',
                                Icons.straighten),
                            _buildDetailChip(
                                'Rs. ${widget.order.totalAmount?.toInt() ?? 0}',
                                Icons.monetization_on),
                            _buildDetailChip(
                                '${widget.order.rating.toStringAsFixed(1)}★',
                                Icons.star),
                          ],
                        ),

                        if (widget.order.items.isNotEmpty) ...[
                          const SizedBox(height: 15),
                          Text(
                            'Items: ${widget.order.items.join(', ')}',
                            style: GoogleFonts.orbitron(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],

                        if (widget.order.specialInstructions != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB74D).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFFB74D).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline,
                                    color: Color(0xFFFFB74D), size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.order.specialInstructions!,
                                    style: GoogleFonts.orbitron(
                                      fontSize: 12,
                                      color: const Color(0xFFFFB74D),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.withOpacity(0.2),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                        color: Colors.red.withOpacity(0.5)),
                                  ),
                                ),
                                onPressed: widget.onReject,
                                child: Text(
                                  'Decline',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00E676),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: widget.onAccept,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle,
                                        color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Accept Order',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpiredCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_off, color: Colors.red, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Expired',
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Text(
                  'Order #${widget.order.id.substring(4, 10)} has been reassigned',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    color: Colors.red.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeOut(delay: const Duration(seconds: 2))
        .slideY(begin: 0, end: -1, delay: const Duration(seconds: 2));
  }

  Widget _buildLocationInfo(
      String type, String address, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                address,
                style: GoogleFonts.orbitron(
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF10B981), size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}
