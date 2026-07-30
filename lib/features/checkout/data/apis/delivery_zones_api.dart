import 'package:dio/dio.dart';
import 'package:patria/core/network/api_client.dart';
import 'package:patria/core/network/api_endpoints.dart';

class DeliveryZonesApi {
  final Dio _dio = ApiClient.instance;

  Future<Response> getDeliveryZones() async {
    return await _dio.get(ApiEndpoints.deliveryZones);
  }
}
