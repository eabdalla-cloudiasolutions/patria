import 'package:patria/core/network/api_client.dart';
import 'package:patria/core/network/api_endpoints.dart';

class ZoneLookupResult {
  final String id;
  final String name;
  final double deliveryFee;
  final double minOrderAmount;

  ZoneLookupResult({
    required this.id,
    required this.name,
    required this.deliveryFee,
    required this.minOrderAmount,
  });

  factory ZoneLookupResult.fromJson(Map<String, dynamic> json) {
    return ZoneLookupResult(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ZoneLookupApi {
  Future<ZoneLookupResult> lookupZone(String zoneName) async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.zoneLookup(zoneName),
    );
    return ZoneLookupResult.fromJson(response.data);
  }
}
