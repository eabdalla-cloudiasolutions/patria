// lib/features/cart/data/apis/coupon_api.dart
import 'package:dio/dio.dart';
import 'package:patria/core/network/api_client.dart';
import 'package:patria/core/network/api_endpoints.dart';

class CouponApi {
  final Dio _dio = ApiClient.instance;

  Future<Map<String, dynamic>> validateCoupon(
    String code,
    double subtotal,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.validateCoupon,
      data: {'code': code, 'orderTotal': subtotal},
    );
    return response.data;
  }
}
