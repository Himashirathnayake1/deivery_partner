class TripHistory {
  final String tripId;
  final String orderId;
  final String customerName;
  final String pickupLocation;
  final String deliveryLocation;
  final double amount;
  final DateTime completedAt;
  final String vehicleType;

  TripHistory({
    required this.tripId,
    required this.orderId,
    required this.customerName,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.amount,
    required this.completedAt,
    required this.vehicleType,
  });

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'orderId': orderId,
      'customerName': customerName,
      'pickupLocation': pickupLocation,
      'deliveryLocation': deliveryLocation,
      'amount': amount,
      'completedAt': completedAt.toIso8601String(),
      'vehicleType': vehicleType,
    };
  }

  factory TripHistory.fromJson(Map<String, dynamic> json) {
    return TripHistory(
      tripId: json['tripId'],
      orderId: json['orderId'],
      customerName: json['customerName'],
      pickupLocation: json['pickupLocation'],
      deliveryLocation: json['deliveryLocation'],
      amount: json['amount'].toDouble(),
      completedAt: DateTime.parse(json['completedAt']),
      vehicleType: json['vehicleType'],
    );
  }
}
