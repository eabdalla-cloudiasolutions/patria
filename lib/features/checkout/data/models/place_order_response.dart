class PlaceOrderResponse {
  final String id; // 👈 added (_id from MongoDB)
  final String orderId;
  final String status;
  final double totalPaid;
  final int pointsEarned;
  final String message;

  PlaceOrderResponse({
    required this.id, // 👈 added
    required this.orderId,
    required this.status,
    required this.totalPaid,
    required this.pointsEarned,
    required this.message,
  });

  factory PlaceOrderResponse.fromJson(Map<String, dynamic> json) {
    return PlaceOrderResponse(
      id: json['_id'] ?? '', // 👈 added
      orderId: json['orderId'] ?? '',
      status: json['status'] ?? '',
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      pointsEarned: json['pointsEarned'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}
