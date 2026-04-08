// lib/features/cart/data/apis/coupon_api.dart
import 'package:dio/dio.dart';
import 'package:erb/core/network/api_client.dart';
import 'package:erb/core/network/api_endpoints.dart';

class CouponApi {
  final Dio _dio = ApiClient.instance;

  Future<Map<String, dynamic>> validateCoupon(
      String code, double subtotal) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.validateCoupon,
        data: {
          'code': code,
          'orderTotal': subtotal, // ✅ key must be 'total'
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Invalid coupon';
        throw Exception(message);
      }
      throw Exception('Failed to validate coupon: ${e.message}');
    }
  }
}
