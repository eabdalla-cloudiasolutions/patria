import 'package:dio/dio.dart';
import 'package:erb/core/network/api_client.dart';
import 'package:erb/core/network/api_endpoints.dart';
import 'package:erb/core/network/api_error_handler.dart';
import 'package:erb/features/checkout/data/models/place_order_request.dart';
import 'package:erb/features/checkout/data/models/place_order_response.dart';

class PlaceOrderApi {
  final Dio _dio = ApiClient.instance;

  Future<PlaceOrderResponse> placeOrder(PlaceOrderRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.placeOrder,
        data: request.toJson(),
      );
      return PlaceOrderResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
