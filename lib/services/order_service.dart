import 'dart:async';
import 'dart:math';
import '../models/delivery_order.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final StreamController<DeliveryOrder> _orderStreamController =
      StreamController<DeliveryOrder>.broadcast(sync: true);

  Stream<DeliveryOrder> get orderStream => _orderStreamController.stream;

  Timer? _orderGenerationTimer;
  final Random _random = Random();

  // Mock data
  final List<String> _customerNames = [
    'John Silva',
    'Sarah Fernando',
    'Mike Perera',
    'Lisa Jayawardena',
    'David Kumar',
    'Emma Wickramasinghe',
    'James Rodriguez',
    'Anna Chen',
    'Robert Dias',
    'Maria Santos',
    'Chris Mendis',
    'Jessica Wong',
  ];

  final List<String> _restaurants = [
    'KFC Colombo',
    'Pizza Hut',
    'McDonald\'s',
    'Burger King',
    'Domino\'s Pizza',
    'Subway',
    'Chinese Dragon',
    'Spice Route',
    'The Commons',
    'Cafe Mocha',
    'Green Cabin',
    'Sakura Japanese',
  ];

  final List<String> _deliveryLocations = [
    'Colombo 03, Colpetty',
    'Colombo 07, Cinnamon Gardens',
    'Kandy City Center',
    'Galle Fort Area',
    'Negombo Beach Road',
    'Mount Lavinia Hotel Area',
    'Dehiwala Junction',
    'Maharagama Town',
    'Nugegoda Shopping Complex',
    'Rajagiriya Center',
    'Battaramulla',
    'Malabe Town Center',
    'Kaduwela Junction',
    'Piliyandala',
  ];

  final List<List<String>> _foodItems = [
    ['Chicken Burger', 'Fries', 'Coke'],
    ['Margherita Pizza', 'Garlic Bread'],
    ['Fried Rice', 'Sweet & Sour Chicken', 'Spring Rolls'],
    ['Big Mac Meal', 'Apple Pie', 'McFlurry'],
    ['Subway Footlong', 'Cookies', 'Orange Juice'],
    ['Kottu Roti', 'Fish Curry', 'Papadam'],
    ['Biriyani', 'Raita', 'Kulfi'],
    ['Pasta Carbonara', 'Caesar Salad', 'Tiramisu'],
  ];

  void startOrderGeneration() {
    _orderGenerationTimer?.cancel();

    // Generate initial order after 5 seconds
    Timer(const Duration(seconds: 5), () => _generateRandomOrder());

    // Continue generating orders periodically with 30-second intervals
    _orderGenerationTimer = Timer.periodic(
      const Duration(seconds: 30), // Fixed 30 seconds between orders
      (timer) => _generateRandomOrder(),
    );
  }

  // Removed _generateInitialOrders and _generateMultipleOrders
  // as we now generate orders one by one with 30-second intervals

  void stopOrderGeneration() {
    _orderGenerationTimer?.cancel();
  }

  void _generateRandomOrder() {
    final orderType =
        OrderType.values[_random.nextInt(OrderType.values.length)];
    final vehicleType =
        VehicleType.values[_random.nextInt(VehicleType.values.length)];
    final distanceKm = 1.5 + (_random.nextDouble() * 8.5); // 1.5 - 10 km
    final baseEarning = 150 + (distanceKm * 25) + (_random.nextDouble() * 100);

    final order = DeliveryOrder(
      id: 'ORD_${DateTime.now().millisecondsSinceEpoch}',
      customerName: _customerNames[_random.nextInt(_customerNames.length)],
      customerPhone: '+9477${_random.nextInt(9000000) + 1000000}',
      pickupLocation: _restaurants[_random.nextInt(_restaurants.length)],
      pickupAddress: 'Al Aksha First Lane, Kinniya-02',
      deliveryLocation: 'Customer Location',
      deliveryAddress:
          _deliveryLocations[_random.nextInt(_deliveryLocations.length)],
      orderItems: orderType == OrderType.food
          ? _foodItems[_random.nextInt(_foodItems.length)]
          : ['Package Delivery'],
      totalAmount: double.parse(baseEarning.toStringAsFixed(0)),
      deliveryFee: 150.0,
      distance: double.parse(distanceKm.toStringAsFixed(1)),
      estimatedTime: (distanceKm * 3).round(),
      orderType: orderType,
      vehicleType: vehicleType,
      createdAt: DateTime.now(),
      pickupLatLng: '6.9271,79.8612',
      deliveryLatLng: '6.8847,79.8574',
      orderNotes: _getRandomInstructions() ?? '',
      estimatedPickupTime:
          DateTime.now().add(Duration(minutes: 5 + _random.nextInt(10))),
      estimatedDeliveryTime:
          DateTime.now().add(Duration(minutes: 20 + _random.nextInt(20))),
      specialInstructions: _getRandomInstructions(),
      isPriority: _random.nextBool() &&
          _random.nextDouble() > 0.7, // 30% chance for priority
      rating: 4.0 + (_random.nextDouble() * 1.0), // 4.0 - 5.0
      restaurantName: orderType == OrderType.food
          ? _restaurants[_random.nextInt(_restaurants.length)]
          : null,
      items: orderType == OrderType.food
          ? _foodItems[_random.nextInt(_foodItems.length)]
          : [],
    );

    _orderStreamController.add(order);
  }

  String? _getRandomInstructions() {
    final instructions = [
      null, // No special instructions
      'Please call when arrived',
      'Leave at the door',
      'Ring the bell twice',
      'Contact security guard',
      'Handle with care - fragile items',
      'Customer will wait at main gate',
      'Apartment 3B, 2nd floor',
      'Behind the blue building',
      'Cash payment preferred',
    ];

    return instructions[_random.nextInt(instructions.length)];
  }

  // Simulate order acceptance
  Future<bool> acceptOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // Always succeed for demo
  }

  // Simulate order rejection
  Future<bool> rejectOrder(String orderId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true; // Always succeed for demo
  }

  // Get earnings statistics
  Map<String, dynamic> getEarningsStats() {
    return {
      'todayEarnings': 1250.0 + (_random.nextDouble() * 500),
      'weeklyEarnings': 8750.0 + (_random.nextDouble() * 2000),
      'monthlyEarnings': 34500.0 + (_random.nextDouble() * 5000),
      'totalTrips': 147 + _random.nextInt(20),
      'todayTrips': 8 + _random.nextInt(5),
      'averageRating': 4.7 + (_random.nextDouble() * 0.3),
      'completionRate': 0.92 + (_random.nextDouble() * 0.07),
    };
  }

  // Generate surge pricing multiplier
  double getSurgePricing() {
    final hour = DateTime.now().hour;

    // Higher surge during lunch (12-2 PM) and dinner (7-9 PM)
    if ((hour >= 12 && hour <= 14) || (hour >= 19 && hour <= 21)) {
      return 1.2 + (_random.nextDouble() * 0.8); // 1.2x - 2.0x
    }

    // Moderate surge during breakfast (8-10 AM)
    if (hour >= 8 && hour <= 10) {
      return 1.1 + (_random.nextDouble() * 0.4); // 1.1x - 1.5x
    }

    return 1.0 + (_random.nextDouble() * 0.2); // 1.0x - 1.2x
  }

  // Check if it's peak hours
  bool isPeakHours() {
    final hour = DateTime.now().hour;
    return (hour >= 8 && hour <= 10) ||
        (hour >= 12 && hour <= 14) ||
        (hour >= 19 && hour <= 21);
  }

  void dispose() {
    _orderGenerationTimer?.cancel();
    _orderStreamController.close();
  }
}
