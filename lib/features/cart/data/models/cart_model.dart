class CartResponse {
  final List<CartItem> items;
  final double total;
  final String? specialRequests;
  final int itemCount;

  CartResponse({
    required this.items,
    required this.total,
    this.specialRequests,
    required this.itemCount,
  });

  factory CartResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CartResponse(items: [], total: 0.0, itemCount: 0);
    }
    return CartResponse(
      items:
          (json['items'] as List?)?.map((e) => CartItem.fromJson(e)).toList() ??
              [],
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      specialRequests: json['specialRequests'], // 👈
      itemCount: json['itemCount'] as int? ?? 0,
    );
  }
}

class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final double price;
  final String? notes;
  final Map<String, dynamic>? customization;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
    this.notes,
    this.customization,
  });

  factory CartItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) throw Exception('CartItem.fromJson: null data');
    return CartItem(
      id: json['_id'] ?? '',
      product: Product.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'],
      customization: json['customization'],
    );
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  final String? category;
  final String? image;
  final int totalInventory;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.category,
    this.image,
    required this.totalInventory,
  });

  factory Product.fromJson(Map<String, dynamic>? json) {
    if (json == null) throw Exception('Product.fromJson: null data');
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'],
      image: json['image'],
      totalInventory: json['totalInventory'] ?? 0,
    );
  }
}
