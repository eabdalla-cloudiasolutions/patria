class AddressModel {
  final String id;
  final String label;
  final String street;
  final String city;
  final String area;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
    required this.area,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    print('🔍 Address JSON: $json'); // ✅ debug - show me the output
    return AddressModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(), // ✅ try both _id and id
      label: (json['label'] ?? '').toString(),
      street: (json['street'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      area: (json['area'] ?? '').toString(),
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'label': label,
        'street': street,
        'city': city,
        'area': area,
        'isDefault': isDefault,
      };
}
