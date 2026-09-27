class OrderModel {
  final String id;
  final String orderNumber;
  final String status;
  final double total;
  final double subtotal;
  final double deliveryFee;
  final double surcharges;
  final double discount;
  final String createdAt;
  final String deliveryAddress;
  final String paymentMethod;
  final List<OrderItemModel> items;
  final bool isReviewed;
  final int? rating;
  final String? specialRequests; // 👈 order‑level special request
  final String? orderNotes; // 👈 root-level notes

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.total,
    required this.subtotal,
    required this.deliveryFee,
    required this.surcharges,
    required this.discount,
    required this.createdAt,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.items,
    required this.isReviewed,
    required this.rating,
    this.specialRequests,
    this.orderNotes,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>?;
    final customer = json['customer'] as Map<String, dynamic>?;
    final payment = json['payment'] as Map<String, dynamic>?;

    return OrderModel(
      id: json['_id'] ?? '',
      orderNumber: json['orderId']?.toString() ?? '',
      status: json['status'] ?? '',
      total: (summary?['total'] ?? 0).toDouble(),
      subtotal: (summary?['subtotal'] ?? 0).toDouble(),
      deliveryFee: (summary?['deliveryFee'] ?? 0).toDouble(),
      surcharges: (summary?['surcharges'] ?? 0).toDouble(),
      discount: (summary?['discount'] ?? 0).toDouble(),
      createdAt: json['createdAt'] ?? '',
      deliveryAddress: customer?['address'] ?? '',
      paymentMethod: payment?['method'] ?? '',
      items: (json['items'] as List?)
              ?.map((e) => OrderItemModel.fromJson(e))
              .toList() ??
          [],
      isReviewed: json['isReviewed'] ?? false,
      rating: json['rating'] as int?,
      specialRequests: json['specialRequests']?.toString(), // 👈 root level
      orderNotes: json['notes']?.toString(), // 👈 root-level notes
    );
  }
}

class OrderItemModel {
  final String productId;
  final String name;
  final String imageUrl;
  final int quantity;
  final double price;
  final List<SelectedVariant> selectedVariants;
  final String? notes; // 👈 per‑item special request

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.price,
    this.selectedVariants = const [],
    this.notes,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    return OrderItemModel(
      productId: product?['_id'] ?? '',
      name: json['name'] ?? product?['name'] ?? '',
      imageUrl: product?['image'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      selectedVariants: (json['selectedVariants'] as List?)
              ?.map((v) => SelectedVariant.fromJson(v))
              .toList() ??
          [],
      notes: json['notes']?.toString(), // 👈 parse notes
    );
  }
}

class SelectedVariant {
  final String group;
  final String option;
  final double priceAdjustment;

  SelectedVariant({
    required this.group,
    required this.option,
    required this.priceAdjustment,
  });

  factory SelectedVariant.fromJson(Map<String, dynamic> json) {
    return SelectedVariant(
      group: json['group'] ?? '',
      option: json['option'] ?? '',
      priceAdjustment: (json['priceAdjustment'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get displayString => option; // or "$group: $option"
}
