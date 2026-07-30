import 'package:dio/dio.dart';
import 'package:patria/core/network/api_client.dart';
import 'package:patria/core/network/api_endpoints.dart';

class TrackOrderApi {
  Future<Response> getOrderById(String orderId) async {
    return await ApiClient.instance.get(ApiEndpoints.trackOrder(orderId));
  }
}
