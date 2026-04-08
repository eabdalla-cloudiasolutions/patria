import 'package:erb/core/network/api_client.dart';
import 'package:erb/core/network/api_endpoints.dart';
import 'package:erb/features/account/data/models/address_model.dart';

class AddressesApi {
  Future<List<AddressModel>> getAddresses() async {
    final response = await ApiClient.instance.get(ApiEndpoints.addresses);
    final List data = response.data as List;
    return data.map((e) => AddressModel.fromJson(e)).toList();
  }

  Future<void> addAddress({
    required String label,
    required String street,
    required String city,
    required String area,
    bool isDefault = false,
  }) async {
    await ApiClient.instance.post(
      ApiEndpoints.addresses,
      data: {
        'label': label,
        'street': street,
        'city': city,
        'area': area,
        'isDefault': isDefault,
      },
    );
  }

  Future<void> deleteAddress(String id) async {
    await ApiClient.instance.delete(ApiEndpoints.deleteAddress(id));
  }

  Future<void> updateAddress({
    required String id,
    required String label,
    required String street,
    required String city,
    required String area,
    required bool isDefault,
  }) async {
    await ApiClient.instance.put(
      ApiEndpoints.updateAddress(id),
      data: {
        'label': label,
        'street': street,
        'city': city,
        'area': area,
        'isDefault': isDefault,
      },
    );
  }
}
