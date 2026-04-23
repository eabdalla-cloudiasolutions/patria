class FavoriteProductModel {
  final String id;
  final String name;
  final String price;
  final String rate;
  final String reviews;
  final String image;
  final bool isFavorite;

  FavoriteProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.rate,
    required this.reviews,
    required this.image,
    required this.isFavorite,
  });

  factory FavoriteProductModel.fromJson(Map<String, dynamic> json) {
    return FavoriteProductModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: json['price']?.toString() ?? '0',
      rate: (json['rate'] ?? 0).toString(),
      reviews: (json['reviewsCount'] ?? json['reviews'] ?? 0).toString(),
      image: json['image'] ?? '',
      isFavorite: true,
    );
  }

  Map<String, String> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'rate': rate,
      'reviews': reviews,
      'image': image,
    };
  }
}
