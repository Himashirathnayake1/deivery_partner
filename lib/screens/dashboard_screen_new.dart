import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/cosmic_background.dart';

import 'wallet_screen.dart';
import 'trip_screen.dart';
import 'orders_screen.dart';
import '../models/delivery_order.dart';
import '../models/trip_history.dart';
import '../services/order_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  int _selectedIndex = 0;
  // Removed _isOnline flag as driver is always online

  // Order service
  final OrderService _orderService = OrderService();
  StreamSubscription<DeliveryOrder>? _orderSubscription;
  DeliveryOrder? _currentIncomingOrder;

  // Mock data
  double _walletBalance = 2450.0;
  final List<DeliveryOrder> _currentOrders = [];
  final List<TripHistory> _tripHistory = [];
  final Set<String> _expiredOrderIds =
      {}; // Track expired orders to prevent re-showing

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Start listening to incoming orders and start order generation
    _initializeOrderService();
  }

  void _initializeOrderService() {
    // Listen to incoming orders
    _orderSubscription = _orderService.orderStream.listen((order) {
      if (mounted) {
        // Don't show expired orders or orders that are already accepted
        if (!_expiredOrderIds.contains(order.id) &&
            !_currentOrders
                .any((existingOrder) => existingOrder.id == order.id)) {
          setState(() {
            _currentIncomingOrder = order;
          });
        }
      }
    });

    // Start generating orders
    _orderService.startOrderGeneration();
  }

  void _acceptOrder() {
    if (_currentIncomingOrder != null) {
      // Create a new order with accepted status
      final acceptedOrder = _currentIncomingOrder!.copyWith(
        status: OrderStatus.accepted, // Set as accepted
      );

      setState(() {
        _currentOrders.add(acceptedOrder);
        _currentIncomingOrder = null; // Clear current incoming order
        _selectedIndex = 1; // Switch to orders tab
      });
    }
  }

  void _declineOrder() {
    if (_currentIncomingOrder != null) {
      final orderId = _currentIncomingOrder!.id;

      setState(() {
        _currentIncomingOrder = null;
        // Add declined order to expired set to prevent it from showing again
        _expiredOrderIds.add(orderId);
      });

      // Optional: You can add analytics or logging here
      // _orderService.rejectOrder(_currentIncomingOrder!.id, 'Driver declined');
    }
  }

  void _cleanupOldExpiredOrders() {
    // Clean up expired order IDs older than 24 hours to prevent memory bloat
    // This is a simple cleanup - in a real app, you'd store timestamps with expired IDs
    if (_expiredOrderIds.length > 100) {
      // Keep only the most recent 50 expired order IDs
      final recentIds =
          _expiredOrderIds.skip(_expiredOrderIds.length - 50).toSet();
      _expiredOrderIds.clear();
      _expiredOrderIds.addAll(recentIds);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _orderSubscription?.cancel();
    _orderService.stopOrderGeneration();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Subtle cosmic background
          Opacity(
            opacity: 0.3,
            child: const CosmicBackground(),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header with online status display
                _buildHeader(),

                // Main content
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back',
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    'Space Rider',
                    style: GoogleFonts.orbitron(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Wallet button only for home section
                  if (_selectedIndex == 0) ...[
                    _buildHeaderWalletButton(),
                    const SizedBox(width: 12),
                  ],
                  // Profile avatar
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF10B981),
                            const Color(0xFF9C27B0),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0xFF10B981).withOpacity(0.1),
                                const Color(0xFF9C27B0).withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.account_circle,
                            size: 28,
                            color: Colors.white.withOpacity(0.9),
                          ),
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
    )
        .animate()
        .slideY(
            begin: -0.3, end: 0, duration: const Duration(milliseconds: 800))
        .fadeIn(duration: const Duration(milliseconds: 600));
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildOnlineDashboard();
      case 1:
        return OrdersScreen(
          acceptedOrders: _currentOrders
              .where((order) => order.status == OrderStatus.accepted)
              .toList(),
          onOrderCompleted: (earnings) {
            setState(() {
              if (earnings > 0) {
                _walletBalance += earnings;
              }
            });
          },
          onOrderStartTrip: (updatedOrder) {
            setState(() {
              // Update the order in the current orders list
              final index =
                  _currentOrders.indexWhere((o) => o.id == updatedOrder.id);
              if (index != -1) {
                _currentOrders[index] = updatedOrder;
              }
              _selectedIndex = 2; // Switch to trip tab
            });
          },
          onOrderExpired: (expiredOrderId) {
            setState(() {
              // Completely remove expired order from current orders
              _currentOrders.removeWhere((o) => o.id == expiredOrderId);
              // Add to expired orders set to prevent re-showing
              _expiredOrderIds.add(expiredOrderId);
              // Clean up old expired orders periodically
              _cleanupOldExpiredOrders();
            });
          },
          onBackPressed: () {
            setState(() {
              _selectedIndex = 0; // Go back to dashboard home
            });
          },
        );
      case 2:
        return TripScreen(
          activeTrips: _currentOrders
              .where((order) =>
                  order.status == OrderStatus.pickupStarted ||
                  order.status == OrderStatus.pickedUp ||
                  order.status == OrderStatus.delivering)
              .toList(),
          onTripCompleted: (order, earnings) {
            setState(() {
              _walletBalance += earnings;

              // Create trip history record
              final tripHistory = TripHistory(
                tripId: 'TRIP_${DateTime.now().millisecondsSinceEpoch}',
                orderId: order.id,
                customerName: order.customerName,
                pickupLocation: order.pickupLocation,
                deliveryLocation: order.deliveryLocation,
                amount: earnings,
                completedAt: DateTime.now(),
                vehicleType: order.vehicleType.displayName,
              );

              _tripHistory.add(tripHistory);
              _currentOrders.removeWhere((o) => o.id == order.id);
            });
          },
          tripHistory: _tripHistory,
        );
      default:
        return _buildOnlineDashboard();
    }
  }

  Widget _buildOnlineDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Incoming Orders Section
          Text(
            'Incoming Orders',
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),

          // Display current incoming order if available
          if (_currentIncomingOrder != null) ...[
            _buildOrderLineItem(_currentIncomingOrder!, true),
            const SizedBox(height: 15),
          ],

          // Display multiple mock orders to show different vehicle types
          _buildMultipleOrders(),
        ],
      ),
    );
  }

  Widget _buildMultipleOrders() {
    // Create sample orders for different vehicle types
    final sampleOrders = [
      DeliveryOrder(
        id: 'ORD_001',
        customerName: 'John Silva',
        customerPhone: '+94771234567',
        pickupLocation: 'KFC Colombo',
        pickupAddress: 'Al Aksha First Lane, Kinniya-02',
        deliveryLocation: 'Independence Square',
        deliveryAddress: 'Independence Square, Colombo 07',
        orderItems: ['Chicken Burger', 'Fries', 'Coke'],
        totalAmount: 850.0,
        deliveryFee: 150.0,
        distance: 3.2,
        estimatedTime: 15,
        vehicleType: VehicleType.bike,
        createdAt: DateTime.now(),
        pickupLatLng: '6.9271,79.8612',
        deliveryLatLng: '6.8847,79.8574',
      ),
      DeliveryOrder(
        id: 'ORD_002',
        customerName: 'Sarah Fernando',
        customerPhone: '+94771234568',
        pickupLocation: 'Pizza Hut',
        pickupAddress: 'Al Aksha First Lane, Kinniya-02',
        deliveryLocation: 'Galle Face Green',
        deliveryAddress: 'Galle Face Green, Colombo 03',
        orderItems: ['Margherita Pizza', 'Garlic Bread'],
        totalAmount: 1200.0,
        deliveryFee: 200.0,
        distance: 5.8,
        estimatedTime: 25,
        vehicleType: VehicleType.car,
        createdAt: DateTime.now(),
        pickupLatLng: '6.9271,79.8612',
        deliveryLatLng: '6.8847,79.8574',
      ),
      DeliveryOrder(
        id: 'ORD_003',
        customerName: 'Mike Perera',
        customerPhone: '+94771234569',
        pickupLocation: 'Dominos Pizza',
        pickupAddress: 'Al Aksha First Lane, Kinniya-02',
        deliveryLocation: 'Mount Lavinia',
        deliveryAddress: 'Mount Lavinia Beach Road',
        orderItems: ['Large Pizza', 'Chicken Wings'],
        totalAmount: 950.0,
        deliveryFee: 180.0,
        distance: 4.1,
        estimatedTime: 20,
        vehicleType: VehicleType.threeWheel,
        createdAt: DateTime.now(),
        pickupLatLng: '6.9271,79.8612',
        deliveryLatLng: '6.8847,79.8574',
      ),
      DeliveryOrder(
        id: 'ORD_004',
        customerName: 'Lisa Jayawardena',
        customerPhone: '+94771234570',
        pickupLocation: 'Furniture Store',
        pickupAddress: 'Al Aksha First Lane, Kinniya-02',
        deliveryLocation: 'Maharagama',
        deliveryAddress: 'Maharagama Town Center',
        orderItems: ['Furniture Set'],
        totalAmount: 2500.0,
        deliveryFee: 400.0,
        distance: 8.5,
        estimatedTime: 45,
        vehicleType: VehicleType.dualPurpose,
        createdAt: DateTime.now(),
        pickupLatLng: '6.9271,79.8612',
        deliveryLatLng: '6.8847,79.8574',
      ),
    ];

    return Column(
      children: [
        ...sampleOrders
            .map((order) => Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: _buildOrderLineItem(order, false),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildOrderLineItem(DeliveryOrder order, bool isIncoming) {
    Widget orderCard = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A1A).withOpacity(0.9),
            const Color(0xFF2A2A2A).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.1),
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
              Text(
                order.vehicleType.icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.vehicleType.displayName,
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    Text(
                      'Order #${order.id.substring(order.id.length - 3)}',
                      style: GoogleFonts.orbitron(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF00E676).withOpacity(0.08),
                          const Color(0xFF10B981).withOpacity(0.12),
                          const Color(0xFF00D4AA).withOpacity(0.10),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFF00E676),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E676).withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: const Color(0xFF00E676).withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF1A1A1A).withOpacity(0.95),
                            const Color(0xFF0F0F0F).withOpacity(0.98),
                          ],
                        ),
                      ),
                      child: Text(
                        'Rs. ${order.totalAmount?.toStringAsFixed(0) ?? '0'}',
                        style: GoogleFonts.nunito(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFFD700),
                          letterSpacing: 1.2,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: const Color(0xFFFFD700).withOpacity(0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                        duration: const Duration(seconds: 4),
                        color: const Color(0xFF00E676).withOpacity(0.15),
                      )
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.02, 1.02),
                        duration: const Duration(milliseconds: 2000),
                      )
                      .then()
                      .scale(
                        begin: const Offset(1.02, 1.02),
                        end: const Offset(1.0, 1.0),
                        duration: const Duration(milliseconds: 2000),
                      ),
                  const SizedBox(height: 6),
                  Text(
                    '${order.distance.toStringAsFixed(1)} km',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Iconsax.location,
                size: 14,
                color: Colors.white60,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${order.pickupLocation} → ${order.deliveryLocation}',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Iconsax.clock,
                size: 14,
                color: Colors.white60,
              ),
              const SizedBox(width: 8),
              Text(
                '${order.estimatedTime} mins',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  color: Colors.white60,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: isIncoming
                    ? _acceptOrder
                    : () => _acceptSpecificOrder(order),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ACCEPT',
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (isIncoming) {
      // For incoming orders, add swipe-to-decline functionality
      return Dismissible(
        key: Key(order.id),
        direction: DismissDirection.vertical,
        onDismissed: (direction) {
          if (direction == DismissDirection.down) {
            _declineOrder();
          }
        },
        background: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.red.withOpacity(0.7),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.thumb_down,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Decline Order',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        child: orderCard,
      );
    } else {
      // For regular orders, just return the card (accept button handles the tap)
      return orderCard;
    }
  }

  void _acceptSpecificOrder(DeliveryOrder order) {
    // Create a new order with accepted status
    final acceptedOrder = order.copyWith(
      status: OrderStatus.accepted,
    );

    setState(() {
      _currentOrders.add(acceptedOrder);
      _selectedIndex = 1; // Switch to orders tab
    });
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A1A).withOpacity(0.9),
            const Color(0xFF2A2A2A).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Iconsax.home, 'Home', 0),
          _buildNavItem(Iconsax.box, 'Orders', 1),
          _buildNavItem(Iconsax.truck, 'Trip', 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF10B981).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF10B981) : Colors.white60,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.orbitron(
                fontSize: 10,
                color: isSelected ? const Color(0xFF10B981) : Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderWalletButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WalletScreen(
              currentBalance: _walletBalance,
              tripHistory: _tripHistory,
            ),
          ),
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4CAF50).withOpacity(0.9),
              const Color(0xFF2E7D32).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
