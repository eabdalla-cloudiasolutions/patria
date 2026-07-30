class AddressModel {
  final String id;
  final String label;
  final String street;
  final String city;
  final String buildingName;
  final String? apartmentNo; // 👈 new
  final String? floor; // 👈 new
  final String? nearbyTrademark; // 👈 new
  final String zone; // 👈 was 'area' → now 'zone' (delivery zone name)
  final String? phone;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
    required this.buildingName,
    this.apartmentNo,
    this.floor,
    this.nearbyTrademark,
    required this.zone,
    this.phone,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      label: json['label'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      buildingName: json['buildingName'] ?? '',
      apartmentNo: json['apartmentNo']?.toString(),
      floor: json['floor']?.toString(),
      nearbyTrademark: json['nearbyTrademark']?.toString(),
      zone: json['zone'] ?? json['area'] ?? '', // fallback to 'area'
      phone: json['phone']?.toString(),
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'label': label,
        'street': street,
        'city': city,
        'buildingName': buildingName,
        if (apartmentNo != null) 'apartmentNo': apartmentNo,
        if (floor != null) 'floor': floor,
        if (nearbyTrademark != null) 'nearbyTrademark': nearbyTrademark,
        'zone': zone,
        if (phone != null) 'phone': phone,
        'isDefault': isDefault,
      };
}
