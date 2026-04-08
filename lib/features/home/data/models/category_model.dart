class CategoryModel {
  final String id;
  final String name;
  final String? image;

  CategoryModel({
    required this.id,
    required this.name,
    this.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        image: json['image'],
      );
}
