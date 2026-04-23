class TrackOrderModel {
  final String id;
  final String orderNumber;
  final String status;
  final String? estimatedArrival;
  final List<TrackOrderHistoryItem> history;
  final TrackOrderCustomer? customer;
  final List<TrackOrderItem> items;
  final TrackOrderDelivery? deliveryDetails;

  TrackOrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    this.estimatedArrival,
    required this.history,
    this.customer,
    required this.items,
    this.deliveryDetails,
  });

  factory TrackOrderModel.fromJson(Map<String, dynamic> json) {
    return TrackOrderModel(
      id: json['_id'] ?? '',
      orderNumber: json['orderId'] ?? '',
      status: json['status'] ?? '',
      estimatedArrival: json['estimatedArrival'],
      history: (json['history'] as List?)
              ?.map((e) =>
                  TrackOrderHistoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      customer: json['customer'] != null
          ? TrackOrderCustomer.fromJson(
              json['customer'] as Map<String, dynamic>)
          : null,
      items: (json['items'] as List?)
              ?.map((e) => TrackOrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      deliveryDetails: json['deliveryDetails'] != null
          ? TrackOrderDelivery.fromJson(
              json['deliveryDetails'] as Map<String, dynamic>)
          : null,
    );
  }

  int get currentStep {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'confirmed':
        return 0;
      case 'preparing':
        return 1;
      case 'out for delivery':
      case 'on the way':
        return 2;
      case 'delivered':
        return 3;
      default:
        return 0;
    }
  }
}

class TrackOrderCustomer {
  final String id;
  final String name;
  final String phone;
  final String address;

  TrackOrderCustomer({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
  });

  factory TrackOrderCustomer.fromJson(Map<String, dynamic> json) {
    return TrackOrderCustomer(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
    );
  }
}

class TrackOrderItem {
  final String productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double price;
  final String? notes;

  TrackOrderItem({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
    this.notes,
  });

  factory TrackOrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? {};
    return TrackOrderItem(
      productId: product['_id'] ?? product['id'] ?? '',
      productName: json['name'] ?? product['name'] ?? '',
      productImage: product['image'],
      quantity: json['quantity'] ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'],
    );
  }
}

class TrackOrderHistoryItem {
  final String status;
  final String timestamp;
  final String? note;

  TrackOrderHistoryItem({
    required this.status,
    required this.timestamp,
    this.note,
  });

  factory TrackOrderHistoryItem.fromJson(Map<String, dynamic> json) {
    return TrackOrderHistoryItem(
      status: json['status'] ?? '',
      timestamp: json['timestamp'] ?? '',
      note: json['note'],
    );
  }
}

class TrackOrderDelivery {
  final String deliveryStatus;
  final String? driverName;

  TrackOrderDelivery({
    required this.deliveryStatus,
    this.driverName,
  });

  factory TrackOrderDelivery.fromJson(Map<String, dynamic> json) {
    return TrackOrderDelivery(
      deliveryStatus: json['deliveryStatus'] ?? '',
      driverName: json['driver']?['name'],
    );
  }
}
