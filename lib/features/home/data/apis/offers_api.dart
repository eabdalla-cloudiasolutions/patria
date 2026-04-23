import 'package:dio/dio.dart';
import 'package:erb/core/network/api_client.dart';
import 'package:erb/core/network/api_endpoints.dart';

class OffersApi {
  final Dio _dio = ApiClient.instance;

  Future<Response> getActiveOffers() async {
    final response = await _dio.get(ApiEndpoints.activeOffers);
    return response;
  }
}
