class OfferModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? discountPercent; // e.g. "-20%"
  final String status;
  final List<String> includedProducts;
  final DateTime startDate;
  final DateTime endDate;
  final String discountType;
  final double discountValue;
  final double minOrderAmount;
  final int usageCount;

  OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.discountPercent,
    required this.status,
    required this.includedProducts,
    required this.startDate,
    required this.endDate,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
    required this.usageCount,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    final double discountValue = (json['discountValue'] ?? 0).toDouble();

    String? discountPercent;
    if (discountValue > 0) {
      discountPercent = '-${discountValue.toInt()}%';
    }

    List<String> includedProducts = [];
    if (json['includedProducts'] != null) {
      includedProducts = List<String>.from(json['includedProducts']);
    }

    String imageUrl = json['image'] ?? '';
    if (imageUrl.startsWith('/')) {
      imageUrl = 'https://admin.erb-roastery-bakery.com$imageUrl';
    }
    if (imageUrl.isEmpty) {
      imageUrl = 'assets/images/Banner.png';
    }

    return OfferModel(
      id: json['_id']?.toString() ?? '',
      title: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: imageUrl,
      discountPercent: discountPercent,
      status: json['status'] ?? 'Active',
      includedProducts: includedProducts,
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      discountType: json['discountType'] ?? '',
      discountValue: discountValue,
      minOrderAmount: (json['minOrderAmount'] ?? 0).toDouble(),
      usageCount: json['usageCount'] ?? 0,
    );
  }

  bool get isActive => status.toLowerCase() == 'active';
  bool get hasDiscount => discountPercent != null;
}
