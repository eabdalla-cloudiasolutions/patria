class DeliveryZone {
  final String id;
  final String name;
  final double deliveryFee;
  final double minOrderAmount;
  final String status;
  final List<String> deliverySchedule;

  DeliveryZone({
    required this.id,
    required this.name,
    required this.deliveryFee,
    required this.minOrderAmount,
    required this.status,
    required this.deliverySchedule,
  });

  factory DeliveryZone.fromJson(Map<String, dynamic> json) {
    List<String> schedule = [];
    if (json['deliverySchedule'] != null &&
        json['deliverySchedule'].isNotEmpty) {
      final firstItem = json['deliverySchedule'][0];
      if (firstItem is List) {
        schedule = List<String>.from(firstItem);
      } else if (firstItem is Map && firstItem.keys.contains('Mon')) {
        // If schedule is a map with days as keys, convert to list
        schedule = firstItem.keys.whereType<String>().toList();
      }
    }
    return DeliveryZone(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      minOrderAmount: (json['minOrderAmount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      deliverySchedule: schedule,
    );
  }
}
