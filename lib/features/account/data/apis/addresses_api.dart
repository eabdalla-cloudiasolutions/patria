import 'package:patria/core/network/api_client.dart';
import 'package:patria/core/network/api_endpoints.dart';
import 'package:patria/features/account/data/models/address_model.dart';

class AddressesApi {
  Future<List<AddressModel>> getAddresses() async {
    final response = await ApiClient.instance.get(ApiEndpoints.addresses);
    final List data = response.data as List;
    return data.map((e) => AddressModel.fromJson(e)).toList();
  }

  Future<AddressModel> addAddress({
    required String label,
    required String street,
    required String city,
    required String buildingName,
    String? apartmentNo,
    String? floor,
    String? nearbyTrademark,
    String? phone,
    required String zone,
    double? lat, // ✅ new
    double? lng, // ✅ new
    bool isDefault = false,
  }) async {
    final response = await ApiClient.instance.post(
      ApiEndpoints.addresses,
      data: {
        'label': label,
        'street': street,
        'city': city,
        'buildingName': buildingName,
        if (apartmentNo != null && apartmentNo.isNotEmpty)
          'apartmentNo': apartmentNo,
        if (floor != null && floor.isNotEmpty) 'floor': floor,
        if (nearbyTrademark != null && nearbyTrademark.isNotEmpty)
          'nearbyTrademark': nearbyTrademark,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'zone': zone,
        'lat': ?lat, // ✅
        'lng': ?lng, // ✅
        'isDefault': isDefault,
      },
    );

    // ✅ The create endpoint's response shape isn't guaranteed to be the
    // flat address object (it may wrap it, or just return a success
    // message). The POST already succeeded by this point, so don't let an
    // unexpected response shape surface as a false "failed to save" error —
    // fall back to re-fetching the list and matching what we just sent.
    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data['_id'] != null || data['id'] != null) {
        return AddressModel.fromJson(data);
      }
      for (final key in ['address', 'data', 'result']) {
        final nested = data[key];
        if (nested is Map<String, dynamic>) {
          return AddressModel.fromJson(nested);
        }
      }
    }

    final addresses = await getAddresses();
    return addresses.lastWhere(
      (a) =>
          a.label == label &&
          a.street == street &&
          a.buildingName == buildingName &&
          a.zone == zone,
      orElse: () => addresses.last,
    );
  }

  Future<void> updateAddress({
    required String id,
    required String label,
    required String street,
    required String city,
    required String buildingName,
    String? apartmentNo,
    String? floor,
    String? nearbyTrademark,
    String? phone,
    required String zone,
    double? lat, // ✅ new
    double? lng, // ✅ new
    required bool isDefault,
  }) async {
    await ApiClient.instance.put(
      ApiEndpoints.updateAddress(id),
      data: {
        'label': label,
        'street': street,
        'city': city,
        'buildingName': buildingName,
        if (apartmentNo != null && apartmentNo.isNotEmpty)
          'apartmentNo': apartmentNo,
        if (floor != null && floor.isNotEmpty) 'floor': floor,
        if (nearbyTrademark != null && nearbyTrademark.isNotEmpty)
          'nearbyTrademark': nearbyTrademark,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'zone': zone,
        'lat': ?lat, // ✅
        'lng': ?lng, // ✅
        'isDefault': isDefault,
      },
    );
  }

  Future<void> deleteAddress(String id) async {
    await ApiClient.instance.delete(ApiEndpoints.deleteAddress(id));
  }

  Future<void> setDefaultAddress(String id) async {
    await ApiClient.instance.patch(ApiEndpoints.setDefaultAddress(id));
  }
}
