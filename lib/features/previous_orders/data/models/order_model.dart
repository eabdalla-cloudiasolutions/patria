class OrderModel {
  final String id;
  final String orderNumber;
  final String status;
  final double total;
  final String createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['_id'] ?? '',
        orderNumber: json['orderNumber']?.toString() ?? '',
        status: json['status'] ?? '',
        total: (json['totalPrice'] ?? 0).toDouble(),
        createdAt: json['createdAt'] ?? '',
        items: (json['items'] as List? ?? [])
            .map((e) => OrderItemModel.fromJson(e))
            .toList(),
      );
}

class OrderItemModel {
  final String name;
  final String imageUrl;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        name: json['product']?['name'] ?? '',
        imageUrl: json['product']?['image'] ?? '',
        quantity: json['quantity'] ?? 1,
        price: (json['price'] ?? 0).toDouble(),
      );
}
