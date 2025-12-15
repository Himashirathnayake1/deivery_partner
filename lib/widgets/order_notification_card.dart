import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/delivery_order.dart';

class OrderNotificationCard extends StatefulWidget {
  final DeliveryOrder order;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onDismiss;

  const OrderNotificationCard({
    super.key,
    required this.order,
    required this.onAccept,
    required this.onReject,
    required this.onDismiss,
  });

  @override
  State<OrderNotificationCard> createState() => _OrderNotificationCardState();
}

class _OrderNotificationCardState extends State<OrderNotificationCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _countdownController;
  late AnimationController _slideController;

  int _remainingSeconds = 30;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _countdownController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _startCountdown();
    _slideController.forward();
  }

  void _startCountdown() {
    _countdownController.forward();

    // Update remaining seconds
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted && _remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });

        if (_remainingSeconds == 0) {
          _autoDismiss();
        }
      }
    });
  }

  void _autoDismiss() async {
    await _slideController.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    _countdownController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Color _getOrderTypeColor() {
    switch (widget.order.orderType) {
      case OrderType.delivery:
        return const Color(0xFFFF6B6B);
      case OrderType.rideshare:
        return const Color(0xFF4ECDC4);
      case OrderType.food:
        return const Color(0xFFFFE66D);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderColor = _getOrderTypeColor();

    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -100 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: orderColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Shimmer background
                    _buildShimmerBackground(orderColor),

                    // Main content
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1A1A2E).withOpacity(0.95),
                            const Color(0xFF16213E).withOpacity(0.95),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 16),
                          _buildOrderDetails(),
                          const SizedBox(height: 16),
                          _buildLocationInfo(),
                          const SizedBox(height: 20),
                          _buildActionButtons(),
                        ],
                      ),
                    ),

                    // Countdown progress bar
                    _buildCountdownProgress(),

                    // Priority badge
                    if (widget.order.isPriority) _buildPriorityBadge(),
                  ],
                ),
              ),
            ).animate().scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.elasticOut,
                ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerBackground(Color orderColor) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                0.3 + (0.4 * _shimmerController.value),
                0.7 + (0.3 * _shimmerController.value),
                1.0,
              ],
              colors: [
                orderColor.withOpacity(0.1),
                orderColor.withOpacity(0.3),
                orderColor.withOpacity(0.2),
                orderColor.withOpacity(0.1),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Order type icon and info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getOrderTypeColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.order.orderType.icon,
            style: const TextStyle(fontSize: 24),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.order.orderType.displayName,
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (widget.order.restaurantName != null)
                Text(
                  widget.order.restaurantName!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ),

        // Earnings display
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00E676),
                    const Color(0xFF00C853),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E676)
                        .withOpacity(0.4 + 0.2 * _pulseController.value),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                'Rs.${widget.order.totalAmount?.toInt() ?? 0}',
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOrderDetails() {
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
          Row(
            children: [
              Icon(Icons.person,
                  color: Colors.white.withOpacity(0.7), size: 16),
              const SizedBox(width: 8),
              Text(
                widget.order.customerName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                widget.order.rating.toStringAsFixed(1),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.route, color: _getOrderTypeColor(), size: 16),
              const SizedBox(width: 8),
              Text(
                '${widget.order.distance} km',
                style: TextStyle(
                  color: _getOrderTypeColor(),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(Icons.access_time,
                  color: Colors.white.withOpacity(0.7), size: 16),
              const SizedBox(width: 4),
              Text(
                '${(widget.order.distance * 3).toInt()}-${(widget.order.distance * 4).toInt()} min',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (widget.order.items.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.restaurant_menu,
                    color: Colors.white.withOpacity(0.7), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.order.items.take(2).join(', ') +
                        (widget.order.items.length > 2
                            ? ' +${widget.order.items.length - 2} more'
                            : ''),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Column(
      children: [
        _buildLocationRow(
          Icons.radio_button_checked,
          'Pickup',
          widget.order.pickupAddress,
          const Color(0xFF4ECDC4),
        ),
        Container(
          margin: const EdgeInsets.only(left: 12),
          height: 20,
          child: CustomPaint(
            painter: DottedLinePainter(),
          ),
        ),
        _buildLocationRow(
          Icons.location_on,
          'Drop-off',
          widget.order.deliveryAddress,
          const Color(0xFFFF6B6B),
        ),
      ],
    );
  }

  Widget _buildLocationRow(
      IconData icon, String label, String address, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
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
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                address,
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
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Reject button
        Expanded(
          child: GestureDetector(
            onTap: () async {
              await _slideController.reverse();
              widget.onReject();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF6B6B).withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.close, color: Color(0xFFFF6B6B), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Decline',
                    style: GoogleFonts.orbitron(
                      color: const Color(0xFFFF6B6B),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Accept button with countdown
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () async {
              await _slideController.reverse();
              widget.onAccept();
            },
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00E676),
                        const Color(0xFF00C853),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E676)
                            .withOpacity(0.4 + 0.2 * _pulseController.value),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Accept ($_remainingSeconds)',
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownProgress() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _countdownController,
        builder: (context, child) {
          return Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                stops: [_countdownController.value, _countdownController.value],
                colors: [
                  _getOrderTypeColor(),
                  Colors.transparent,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriorityBadge() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.priority_high, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              'PRIORITY',
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ).animate().shimmer(
            duration: const Duration(seconds: 2),
            color: Colors.white.withOpacity(0.5),
          ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
