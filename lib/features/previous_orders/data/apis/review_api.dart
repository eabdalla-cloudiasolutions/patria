import 'package:dio/dio.dart';
import 'package:patria/core/network/api_client.dart';
import 'package:patria/core/network/api_endpoints.dart';

class ReviewApi {
  Future<void> submitReview({
    required String orderId,
    required int rating,
    required String comment,
    required List<String> tags,
  }) async {
    try {
      await ApiClient.instance.post(
        ApiEndpoints.reviews,
        data: {
          'orderId': orderId,
          'rating': rating,
          'comment': comment,
          'tags': tags,
        },
      );
    } on DioException {
      rethrow;
    }
  }
}
