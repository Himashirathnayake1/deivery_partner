import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/delivery_order.dart';

class ProfessionalOrderService {
  static final ProfessionalOrderService _instance = ProfessionalOrderService._internal();
  factory ProfessionalOrderService() => _instance;
  ProfessionalOrderService._internal();

  final StreamController<DeliveryOrder> _orderController = StreamController<DeliveryOrder>.broadcast();
  final StreamController<List<DeliveryOrder>> _ordersListController = StreamController<List<DeliveryOrder>>.broadcast();
  
  Timer? _orderTimer;
  List<DeliveryOrder> _activeOrders = [];
  bool _isOnline = false;
  final Random _random = Random();

  // Streams
  Stream<DeliveryOrder> get newOrderStream => _orderController.stream;
  Stream<List<DeliveryOrder>> get ordersListStream => _ordersListController.stream;

  // Professional pickup and delivery locations
  final List<Map<String, dynamic>> _locations = [
    {'name': 'McDonald\'s - Mall Road', 'area': 'Commercial District', 'lat': 6.9271, 'lng': 79.8612},
    {'name': 'KFC - Galle Road', 'area': 'Bambalapitiya', 'lat': 6.8847, 'lng': 79.8574},
    {'name': 'Pizza Hut - Kandy Road', 'area': 'Malabe', 'lat': 6.9147, 'lng': 79.9729},
    {'name': 'Burger King - Unity Plaza', 'area': 'Colombo 04', 'lat': 6.8962, 'lng': 79.8562},
    {'name': 'Subway - Liberty Plaza', 'area': 'Colombo 03', 'lat': 6.9147, 'lng': 79.8480},
    {'name': 'Domino\'s Pizza - Nugegoda', 'area': 'Nugegoda', 'lat': 6.8720, 'lng': 79.8854},
    {'name': 'Chinese Dragon - Dehiwala', 'area': 'Dehiwala', 'lat': 6.8520, 'lng': 79.8630},
    {'name': 'Perera & Sons - Pettah', 'area': 'Colombo 11', 'lat': 6.9344, 'lng': 79.8428},
    {'name': 'Keells Super - Rajagiriya', 'area': 'Rajagiriya', 'lat': 6.9069, 'lng': 79.8920},
    {'name': 'Arpico Supercentre - Wellawatte', 'area': 'Wellawatte', 'lat': 6.8667, 'lng': 79.8575},
  ];

  final List<Map<String, dynamic>> _deliveryAreas = [
    {'name': 'Apartment 12B, Crescat Residencies', 'area': 'Colombo 03', 'lat': 6.9147, 'lng': 79.8480},
    {'name': 'House No. 45/2, Duplication Road', 'area': 'Colombo 04', 'lat': 6.8962, 'lng': 79.8562},
    {'name': 'Unity Apartments, Floor 8', 'area': 'Colombo 04', 'lat': 6.8947, 'lng': 79.8547},
    {'name': 'Bagatelle Road, House 23A', 'area': 'Colombo 03', 'lat': 6.9089, 'lng': 79.8456},
    {'name': 'Havelock Gardens, Villa 7', 'area': 'Colombo 05', 'lat': 6.8847, 'lng': 79.8574},
    {'name': 'Kirimandala Mawatha, House 156', 'area': 'Narahenpita', 'lat': 6.9023, 'lng': 79.8751},
    {'name': 'Baseline Road, Apartment 4C', 'area': 'Colombo 09', 'lat': 6.8895, 'lng': 79.8533},
    {'name': 'Nawala Road, House 89/1', 'area': 'Nugegoda', 'lat': 6.8720, 'lng': 79.8854},
    {'name': 'High Level Road, Building 3B', 'area': 'Nugegoda', 'lat': 6.8698, 'lng': 79.8842},
    {'name': 'Galle Road, Apartment 15A', 'area': 'Dehiwala', 'lat': 6.8520, 'lng': 79.8630},
  ];

  final List<String> _customerNames = [
    'Kamal Perera', 'Saman Silva', 'Nimal Fernando', 'Ruwan Jayawardena',
    'Kumara Bandara', 'Priya Wickramasinghe', 'Sanduni Rajapaksa', 'Tharaka Mendis',
    'Chamara Gunasekara', 'Dilini Rathnayake', 'Kasun Wijeratne', 'Nadeesha Gunaratne',
    'Asanka Dharmasena', 'Malini Samaraweera', 'Chathura Liyanage', 'Vindya Senanayake'
  ];

  final List<String> _orderItems = [
    'Chicken Rice & Curry with Papadam',
    'Large Cheese Pizza with Extra Toppings',
    'Spicy Chicken Burger Combo with Fries',
    'Family Pack Fried Chicken (8 pcs)',
    'Vegetarian Noodles with Spring Rolls',
    'BBQ Chicken Submarine (Footlong)',
    'Kottu Roti with Chicken and Egg',
    'Fish & Chips with Garlic Bread',
    'Biryani Rice with Raita and Pickle',
    'Club Sandwich with French Fries',
    'Chinese Mixed Fried Rice (Large)',
    'Grilled Chicken with Mashed Potato',
  ];

  void startOrderGeneration() {
    if (_orderTimer?.isActive ?? false) return;
    
    // Generate orders professionally with 30 second intervals
    _orderTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isOnline) {
        _generateNewOrder();
      }
    });
  }

  void stopOrderGeneration() {
    _orderTimer?.cancel();
  }

  void setOnlineStatus(bool isOnline) {
    _isOnline = isOnline;
    if (!isOnline) {
      _activeOrders.clear();
      _ordersListController.add(_activeOrders);
    }
  }

  void _generateNewOrder() async {
    // Generate realistic order details
    final pickup = _locations[_random.nextInt(_locations.length)];
    final delivery = _deliveryAreas[_random.nextInt(_deliveryAreas.length)];
    final customer = _customerNames[_random.nextInt(_customerNames.length)];
    final items = _orderItems[_random.nextInt(_orderItems.length)];
    
    // Calculate realistic pricing
    final baseAmount = 850.0 + (_random.nextDouble() * 1500.0); // 850 - 2350 LKR
    final deliveryFee = 150.0 + (_random.nextDouble() * 100.0); // 150 - 250 LKR
    final totalAmount = baseAmount + deliveryFee;
    
    // Calculate realistic distance and time
    final distance = 2.5 + (_random.nextDouble() * 8.0); // 2.5 - 10.5 km
    final estimatedTime = (distance * 3) + _random.nextInt(10); // Realistic travel time

    final order = DeliveryOrder(
      id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
      customerName: customer,
      customerPhone: '+94${70 + _random.nextInt(7)}${_random.nextInt(1000000).toString().padLeft(7, '0')}',
      pickupLocation: pickup['name'],
      pickupAddress: '${pickup['name']}, ${pickup['area']}',
      deliveryLocation: delivery['name'],
      deliveryAddress: '${delivery['name']}, ${delivery['area']}',
      orderItems: [items],
      totalAmount: double.parse(totalAmount.toStringAsFixed(2)),
      deliveryFee: double.parse(deliveryFee.toStringAsFixed(2)),
      distance: double.parse(distance.toStringAsFixed(1)),
      estimatedTime: estimatedTime.round(),
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      pickupLatLng: '${pickup['lat']},${pickup['lng']}',
      deliveryLatLng: '${delivery['lat']},${delivery['lng']}',
      orderNotes: _generateOrderNotes(),
    );

    // Add to active orders
    _activeOrders.add(order);
    if (!_ordersListController.isClosed) {
      _ordersListController.add(_activeOrders);
    }
    if (!_orderController.isClosed) {
      _orderController.add(order);
    }

    // Play notification sound
    await _playNotificationSound();
    
    // Vibrate device
    await HapticFeedback.heavyImpact();
    
    // Save to preferences
    await _saveOrderHistory(order);
  }

  String _generateOrderNotes() {
    final notes = [
      'Ring the bell twice. Apartment is on the 2nd floor.',
      'Call when you arrive. Gate code: 1234.',
      'Leave at reception if no answer.',
      'Please bring change for Rs. 5000.',
      'Handle with care - contains drinks.',
      'Customer prefers contactless delivery.',
      'Security guard will collect the order.',
      'Park near the main entrance.',
      'Call 5 minutes before arrival.',
      'Extra spicy - customer request.',
    ];
    
    if (_random.nextBool()) {
      return notes[_random.nextInt(notes.length)];
    }
    return '';
  }

  Future<void> _playNotificationSound() async {
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      print('Failed to play notification sound: $e');
    }
  }

  Future<void> _saveOrderHistory(DeliveryOrder order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orderHistoryJson = prefs.getStringList('order_history') ?? [];
      
      orderHistoryJson.add(order.toJson());
      
      // Keep only last 50 orders
      if (orderHistoryJson.length > 50) {
        orderHistoryJson.removeAt(0);
      }
      
      await prefs.setStringList('order_history', orderHistoryJson);
      
      // Update driver statistics
      await _updateDriverStats();
    } catch (e) {
      print('Failed to save order history: $e');
    }
  }

  Future<void> _updateDriverStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final totalOrders = prefs.getInt('total_orders') ?? 0;
      final todayOrders = prefs.getInt('today_orders') ?? 0;
      final totalEarnings = prefs.getDouble('total_earnings') ?? 0.0;
      
      await prefs.setInt('total_orders', totalOrders + 1);
      await prefs.setInt('today_orders', todayOrders + 1);
      await prefs.setDouble('total_earnings', totalEarnings + (_activeOrders.last.totalAmount ?? 0));
      
      // Update last order date
      await prefs.setString('last_order_date', DateTime.now().toIso8601String());
    } catch (e) {
      print('Failed to update driver stats: $e');
    }
  }

  void acceptOrder(String orderId) {
    final index = _activeOrders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      _activeOrders[index] = _activeOrders[index].copyWith(status: OrderStatus.accepted);
      _ordersListController.add(_activeOrders);
    }
  }

  void rejectOrder(String orderId) {
    _activeOrders.removeWhere((order) => order.id == orderId);
    _ordersListController.add(_activeOrders);
  }

  void removeExpiredOrder(String orderId) {
    rejectOrder(orderId);
  }

  List<DeliveryOrder> get currentOrders => _activeOrders;

  void dispose() {
    _orderTimer?.cancel();
    if (!_orderController.isClosed) {
      _orderController.close();
    }
    if (!_ordersListController.isClosed) {
      _ordersListController.close();
    }
  }
}
