import 'package:dio/dio.dart';
import 'package:erb/core/network/api_client.dart';
import 'package:erb/features/account/data/models/loyalty_points_model.dart';

class LoyaltyRepo {
  final Dio _dio = ApiClient.instance;

  Future<LoyaltyPointsModel> getLoyaltyPoints() async {
    try {
      final response = await _dio.get('/users/loyalty');

      if (response.statusCode == 200 && response.data != null) {
        return LoyaltyPointsModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load loyalty points');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
