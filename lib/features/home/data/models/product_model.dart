class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final double rate;
  final int reviewCount;
  final bool isAvailable;
  final List<String> images;
  final List<String>? sizes; // 👈 أضف هذا
  final List<String>? otherOptions;
  final CustomizationOptions? customizationOptions; // 👈 أضف هذا

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.rate = 0.0,
    this.reviewCount = 0,
    this.isAvailable = true,
    this.images = const [],
    this.sizes,
    this.otherOptions,
    this.customizationOptions, // 👈 أضف هذا
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Handle customization options
    CustomizationOptions? customizationOptions;
    if (json['customizationOptions'] != null) {
      customizationOptions =
          CustomizationOptions.fromJson(json['customizationOptions']);
    }

    return ProductModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      imageUrl: json['image'] ?? json['imageUrl'] ?? '',
      rate: (json['rate'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? json['reviews'] ?? 0,
      isAvailable: json['isActive'] ?? true,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      sizes: json['sizes'] != null ? List<String>.from(json['sizes']) : null,
      otherOptions: json['otherOptions'] != null
          ? List<String>.from(json['otherOptions'])
          : null,
      customizationOptions: customizationOptions,
    );
  }

  // Getter to check if product has customization options
  bool get hasCustomization =>
      customizationOptions != null &&
      (customizationOptions!.hasRoastLevels ||
          customizationOptions!.hasGrindTypes);

  // Get all available options combined
  List<String> get allCustomOptions {
    final options = <String>[];
    if (customizationOptions?.roastLevels != null) {
      options.addAll(customizationOptions!.roastLevels!);
    }
    if (customizationOptions?.grindTypes != null) {
      options.addAll(customizationOptions!.grindTypes!);
    }
    return options;
  }
}

class CustomizationOptions {
  final List<String>? roastLevels;
  final List<String>? grindTypes;

  CustomizationOptions({
    this.roastLevels,
    this.grindTypes,
  });

  factory CustomizationOptions.fromJson(Map<String, dynamic> json) {
    return CustomizationOptions(
      roastLevels: json['roastLevels'] != null
          ? List<String>.from(json['roastLevels'])
          : null,
      grindTypes: json['grindTypes'] != null
          ? List<String>.from(json['grindTypes'])
          : null,
    );
  }

  bool get hasRoastLevels => roastLevels != null && roastLevels!.isNotEmpty;
  bool get hasGrindTypes => grindTypes != null && grindTypes!.isNotEmpty;
}

class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final int productCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.productCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      productCount: json['productCount'] ?? 0,
    );
  }
}
