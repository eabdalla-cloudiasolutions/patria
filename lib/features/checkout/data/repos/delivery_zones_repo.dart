import 'package:dio/dio.dart';
import 'package:erb/core/network/api_error_handler.dart';
import 'package:erb/features/checkout/data/apis/delivery_zones_api.dart';
import 'package:erb/features/checkout/data/models/delivery_zone_model.dart';

class DeliveryZonesRepo {
  final DeliveryZonesApi _api = DeliveryZonesApi();

  Future<List<DeliveryZone>> getDeliveryZones() async {
    try {
      final response = await _api.getDeliveryZones();
      List<dynamic> data =
          response.data is List ? response.data : (response.data['data'] ?? []);
      return data.map((json) => DeliveryZone.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
