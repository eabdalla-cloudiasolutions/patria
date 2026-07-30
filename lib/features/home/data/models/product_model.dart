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
  final List<String>? sizes;
  final List<String>? otherOptions;
  final bool haveCustomizationOption; // new
  final List<VariantGroup> variantGroups; // new
  final bool isIngredient;

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
    this.haveCustomizationOption = false,
    this.variantGroups = const [],
    required this.isIngredient,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
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
      haveCustomizationOption: json['haveCustomizationOption'] ?? false,
      variantGroups: (json['variantGroups'] as List?)
              ?.map((e) => VariantGroup.fromJson(e))
              .toList() ??
          [],
      isIngredient: json['isIngredient'] ?? true,
    );
  }

  // Helper to check if any variant group exists
  bool get hasCustomization =>
      haveCustomizationOption && variantGroups.isNotEmpty;

  // Helper to get total price adjustment for selected options
  double calculateTotalAdjustment(Map<String, VariantOption> selected) {
    double total = 0;
    for (var group in variantGroups) {
      final selectedOption = selected[group.name];
      if (selectedOption != null) {
        total += selectedOption.priceAdjustment;
      }
    }
    return total;
  }

  // Final price after adding customization adjustments
  double getFinalPrice(Map<String, VariantOption> selected) =>
      price + calculateTotalAdjustment(selected);
}

// variant_group.dart

class VariantGroup {
  final String name;
  final bool required;
  final List<VariantOption> options;

  VariantGroup({
    required this.name,
    required this.required,
    required this.options,
  });

  factory VariantGroup.fromJson(Map<String, dynamic> json) {
    return VariantGroup(
      name: json['name'] ?? '',
      required: json['required'] ?? false,
      options: (json['options'] as List?)
              ?.map((e) => VariantOption.fromJson(e))
              .toList() ??
          [],
    );
  }
}

// variant_option.dart
class VariantOption {
  final String label;
  final double priceAdjustment;

  VariantOption({
    required this.label,
    required this.priceAdjustment,
  });

  factory VariantOption.fromJson(Map<String, dynamic> json) {
    return VariantOption(
      label: json['label'] ?? '',
      priceAdjustment: (json['priceAdjustment'] ?? 0).toDouble(),
    );
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
