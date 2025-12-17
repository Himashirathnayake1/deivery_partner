import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/liquid_notification.dart';
import '../models/delivery_order.dart';
import '../services/professional_order_service.dart';
import '../utils/map_utils.dart';

class OrdersScreen extends StatefulWidget {
  final List<DeliveryOrder>? acceptedOrders;
  final Function(double)? onOrderCompleted;
  final Function(DeliveryOrder)? onOrderStartTrip;
  final Function(String)? onOrderExpired; // New callback for expired orders
  final VoidCallback? onBackPressed;

  const OrdersScreen({
    super.key,
    this.acceptedOrders,
    this.onOrderCompleted,
    this.onOrderStartTrip,
    this.onOrderExpired,
    this.onBackPressed,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  final ProfessionalOrderService _professionalOrderService =
      ProfessionalOrderService();
  List<DeliveryOrder> _acceptedOrders = [];
  Map<String, Timer> _confirmationTimers = {};
  Map<String, DateTime> _acceptedTimes = {};

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Initialize with accepted orders from parent
    if (widget.acceptedOrders != null) {
      _acceptedOrders = List.from(widget.acceptedOrders!);
      // Start timers for existing orders
      for (final order in _acceptedOrders) {
        if (order.status == OrderStatus.accepted) {
          _acceptedTimes[order.id] = DateTime.now();
          _startConfirmationTimer(order);
        }
      }
    }

    // Listen for updates to accepted orders
    _professionalOrderService.ordersListStream.listen((orders) {
      if (mounted) {
        final newAcceptedOrders = orders
            .where((order) => order.status == OrderStatus.accepted)
            .toList();

        // Start timer for newly accepted orders
        for (final order in newAcceptedOrders) {
          if (!_acceptedTimes.containsKey(order.id)) {
            _acceptedTimes[order.id] = DateTime.now();
            _startConfirmationTimer(order);
          }
        }

        setState(() {
          _acceptedOrders = newAcceptedOrders;
        });
      }
    });
  }

  void _startConfirmationTimer(DeliveryOrder order) {
    final timer = Timer(const Duration(minutes: 30), () {
      if (mounted) {
        setState(() {
          _acceptedOrders.removeWhere((o) => o.id == order.id);
          _acceptedTimes.remove(order.id);
        });

        // Notify parent dashboard that order has expired
        if (widget.onOrderExpired != null) {
          widget.onOrderExpired!(order.id);
        }

        LiquidNotification.warning(
          context,
          'Order #${order.id.substring(order.id.length - 6)} expired after 30 minutes',
        );
      }
      _confirmationTimers.remove(order.id);
    });

    _confirmationTimers[order.id] = timer;
  }

  Duration _getRemainingTime(String orderId) {
    if (!_acceptedTimes.containsKey(orderId)) return Duration.zero;

    final acceptedTime = _acceptedTimes[orderId]!;
    final expiryTime = acceptedTime.add(const Duration(minutes: 30));
    final remaining = expiryTime.difference(DateTime.now());

    return remaining.isNegative ? Duration.zero : remaining;
  }

  void _openPickupLocationInMap(DeliveryOrder order) async {
    try {
      // Try to use coordinates first if available
      final coords = MapUtils.parseCoordinates(order.pickupLatLng);

      if (coords != null) {
        await MapUtils.openGoogleMaps(
          latitude: coords['latitude'],
          longitude: coords['longitude'],
        );
      } else {
        // Fallback to address
        await MapUtils.openGoogleMaps(
          address: order.pickupAddress,
        );
      }
    } catch (e) {
      if (mounted) {
        LiquidNotification.error(
          context,
          'Could not open map. Please check your internet connection.',
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _confirmationTimers.values.forEach((timer) => timer.cancel());
    super.dispose();
  }

  void _startTrip(DeliveryOrder order) {
    // Cancel the confirmation timer
    _confirmationTimers[order.id]?.cancel();
    _confirmationTimers.remove(order.id);
    _acceptedTimes.remove(order.id);

    // Update order status to delivering
    final updatedOrder = order.copyWith(
      status: OrderStatus.delivering,
    );

    setState(() {
      _acceptedOrders.removeWhere((o) => o.id == order.id);
    });

    // Notify the dashboard about the trip start
    if (widget.onOrderStartTrip != null) {
      widget.onOrderStartTrip!(updatedOrder);
    }

    LiquidNotification.success(
      context,
      'Trip started! Go to Trip section to complete delivery.',
    );
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
            child: _buildOnlineContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineContent() {
    return Column(
      children: [
        // Orders List
        Expanded(
          child: _acceptedOrders.isEmpty
              ? _buildEmptyAcceptedOrders()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _acceptedOrders.length,
                  itemBuilder: (context, index) {
                    final order = _acceptedOrders[index];
                    return _buildAcceptedOrderCard(order)
                        .animate(delay: Duration(milliseconds: index * 150))
                        .slideX(begin: 1.0, end: 0)
                        .fadeIn();
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyAcceptedOrders() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4CAF50).withOpacity(0.3),
                    const Color(0xFF4CAF50).withOpacity(0.1),
                  ],
                ),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 60,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Accepted Orders',
              style: GoogleFonts.orbitron(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Accept orders from the dashboard\nto see them here for completion.',
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                fontSize: 14,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptedOrderCard(DeliveryOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
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
                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(order.id.length - 6)}',
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Ready for completion',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs. ${order.totalAmount?.toStringAsFixed(0) ?? '0'}',
                    style: GoogleFonts.orbitron(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, snapshot) {
                      final remaining = _getRemainingTime(order.id);
                      final minutes = remaining.inMinutes;
                      final seconds = remaining.inSeconds % 60;

                      return Text(
                        '${minutes}m ${seconds}s left',
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          color: remaining.inMinutes < 5
                              ? Colors.red
                              : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Order Details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF4CAF50).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Details',
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                    'Order ID:',
                    '#${order.id.substring(order.id.length - 6)}',
                    Icons.receipt_long),
                _buildInfoRow(
                    'Order Support:',
                    '0755077070',
                    Icons.phone,
                    onPhoneTap: () => _makePhoneCall('0755077070')),
                _buildInfoRow(
                    'Pickup Location:', order.pickupAddress, Icons.restaurant,
                    onMapTap: () {
                  _openPickupLocationInMap(order);
                }),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Delivery Info
          _buildInfoRow('Delivery:', order.deliveryLocation, Icons.location_on),
          _buildInfoRow('Distance:', '${order.distance} km', Icons.straighten),

          const SizedBox(height: 16),

          // Ordered Items by Receiver
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_cart,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ordered Items by Receiver:',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildOrderItem('Soda - 100ml', '24 units', 'Rs. 240.00'),
                _buildOrderItem('Kotmale Milk', '20 units', 'Rs. 400.00'),
                _buildOrderItem('Rice Packet', '5 units', 'Rs. 150.00'),
                const Divider(color: Colors.white24, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Items:',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '49 items',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Start Trip button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _startTrip(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_shipping, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'START TRIP',
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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

  Widget _buildInfoRow(String label, String value, IconData icon,
      {VoidCallback? onMapTap, VoidCallback? onPhoneTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white60),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: onPhoneTap != null ? const Color(0xFF4CAF50) : Colors.white,
              ),
            ),
          ),
          if (onMapTap != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onMapTap,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4285F4),
                      Color(0xFF34A853)
                    ], // Google colors
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4285F4).withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.navigation, // Better Google Maps style icon
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          if (onPhoneTap != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onPhoneTap,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4CAF50),
                      Color(0xFF45A049)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.call,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItem(String itemName, String quantity, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              itemName,
              style: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              quantity,
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ),
          Expanded(
            child: Text(
              price,
              textAlign: TextAlign.right,
              style: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4CAF50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
