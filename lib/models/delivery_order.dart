enum OrderType {
  delivery,
  rideshare,
  food,
}

enum VehicleType {
  threeWheel,
  car,
  bike,
  dualPurpose,
}

enum OrderStatus {
  pending,
  accepted,
  pickupStarted,
  pickedUp,
  delivering,
  delivered,
  cancelled,
}

class DeliveryOrder {
  final String id;
  final String customerName;
  final String customerPhone;
  final String pickupLocation;
  final String pickupAddress;
  final String deliveryLocation;
  final String deliveryAddress;
  final List<String> orderItems;
  final double? totalAmount;
  final double? deliveryFee;
  final double distance;
  final int estimatedTime;
  final OrderStatus status;
  final DateTime createdAt;
  final String pickupLatLng;
  final String deliveryLatLng;
  final String orderNotes;
  final OrderType orderType;
  final VehicleType vehicleType;
  final DateTime? estimatedPickupTime;
  final DateTime? estimatedDeliveryTime;
  final String? specialInstructions;
  final bool isPriority;
  final double rating;
  final String? restaurantName;
  final List<String> items;

  DeliveryOrder({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.pickupLocation,
    required this.pickupAddress,
    required this.deliveryLocation,
    required this.deliveryAddress,
    required this.orderItems,
    this.totalAmount,
    this.deliveryFee,
    required this.distance,
    required this.estimatedTime,
    this.status = OrderStatus.pending,
    required this.createdAt,
    required this.pickupLatLng,
    required this.deliveryLatLng,
    this.orderNotes = '',
    this.orderType = OrderType.food,
    this.vehicleType = VehicleType.bike,
    this.estimatedPickupTime,
    this.estimatedDeliveryTime,
    this.specialInstructions,
    this.isPriority = false,
    this.rating = 0.0,
    this.restaurantName,
    this.items = const [],
  });

  DeliveryOrder copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? pickupLocation,
    String? pickupAddress,
    String? deliveryLocation,
    String? deliveryAddress,
    List<String>? orderItems,
    double? totalAmount,
    double? deliveryFee,
    double? distance,
    int? estimatedTime,
    OrderStatus? status,
    DateTime? createdAt,
    String? pickupLatLng,
    String? deliveryLatLng,
    String? orderNotes,
    OrderType? orderType,
    VehicleType? vehicleType,
    DateTime? estimatedPickupTime,
    DateTime? estimatedDeliveryTime,
    String? specialInstructions,
    bool? isPriority,
    double? rating,
    String? restaurantName,
    List<String>? items,
  }) {
    return DeliveryOrder(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      orderItems: orderItems ?? this.orderItems,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      distance: distance ?? this.distance,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      pickupLatLng: pickupLatLng ?? this.pickupLatLng,
      deliveryLatLng: deliveryLatLng ?? this.deliveryLatLng,
      orderNotes: orderNotes ?? this.orderNotes,
      orderType: orderType ?? this.orderType,
      vehicleType: vehicleType ?? this.vehicleType,
      estimatedPickupTime: estimatedPickupTime ?? this.estimatedPickupTime,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      isPriority: isPriority ?? this.isPriority,
      rating: rating ?? this.rating,
      restaurantName: restaurantName ?? this.restaurantName,
      items: items ?? this.items,
    );
  }

  String toJson() {
    return '''{
      "id": "$id",
      "customerName": "$customerName",
      "customerPhone": "$customerPhone",
      "pickupLocation": "$pickupLocation",
      "pickupAddress": "$pickupAddress",
      "deliveryLocation": "$deliveryLocation",
      "deliveryAddress": "$deliveryAddress",
      "orderItems": ${orderItems.map((item) => '"$item"').toList()},
      "totalAmount": $totalAmount,
      "deliveryFee": $deliveryFee,
      "distance": $distance,
      "estimatedTime": $estimatedTime,
      "status": "${status.name}",
      "createdAt": "${createdAt.toIso8601String()}",
      "pickupLatLng": "$pickupLatLng",
      "deliveryLatLng": "$deliveryLatLng",
      "orderNotes": "$orderNotes"
    }''';
  }
}

extension OrderTypeExtension on OrderType {
  String get displayName {
    switch (this) {
      case OrderType.delivery:
        return 'Package Delivery';
      case OrderType.rideshare:
        return 'Ride Share';
      case OrderType.food:
        return 'Food Delivery';
    }
  }

  String get icon {
    switch (this) {
      case OrderType.delivery:
        return '📦';
      case OrderType.rideshare:
        return '🚗';
      case OrderType.food:
        return '🍽️';
    }
  }
}

extension VehicleTypeExtension on VehicleType {
  String get displayName {
    switch (this) {
      case VehicleType.threeWheel:
        return 'Belongs To Three Wheel';
      case VehicleType.car:
        return 'Belongs To Car';
      case VehicleType.bike:
        return 'Belongs To Bike';
      case VehicleType.dualPurpose:
        return 'Belongs To Dual Purpose Vehicles';
    }
  }

  String get icon {
    switch (this) {
      case VehicleType.threeWheel:
        return '🛺';
      case VehicleType.car:
        return '🚗';
      case VehicleType.bike:
        return '🏍️';
      case VehicleType.dualPurpose:
        return '🚛';
    }
  }

  String get color {
    switch (this) {
      case VehicleType.threeWheel:
        return '#FF9800';
      case VehicleType.car:
        return '#2196F3';
      case VehicleType.bike:
        return '#4CAF50';
      case VehicleType.dualPurpose:
        return '#9C27B0';
    }
  }
}

extension OrderTypeColorExtension on OrderType {
  String get color {
    switch (this) {
      case OrderType.delivery:
        return '#FF6B6B';
      case OrderType.rideshare:
        return '#4ECDC4';
      case OrderType.food:
        return '#FFE66D';
    }
  }
}
