import 'package:dio/dio.dart';
import 'package:erb/core/network/api_client.dart';
import 'package:erb/core/network/api_endpoints.dart';
import 'package:erb/core/network/api_error_handler.dart';
import 'package:erb/features/checkout/data/models/checkout_preview_model.dart';

class CheckoutPreviewApi {
  final Dio _dio = ApiClient.instance;

  Future<CheckoutPreviewModel> getCheckoutPreview({
    required double subtotal,
    required double deliveryFee,
    required double serviceFee,
    double couponDiscount = 0,
    int pointsToRedeem = 0,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.checkoutPreview,
        data: {
          'subtotal': subtotal,
          'deliveryFee': deliveryFee,
          'serviceFee': serviceFee,
          'couponDiscount': couponDiscount,
          'pointsToRedeem': pointsToRedeem,
        },
      );
      return CheckoutPreviewModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiErrorHandler.handle(e);
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }
}
