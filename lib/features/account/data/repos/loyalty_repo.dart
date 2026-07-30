import 'package:dio/dio.dart';
import 'package:patria/core/network/api_client.dart';
import 'package:patria/core/network/api_endpoints.dart'; // add this
import 'package:patria/features/account/data/models/loyalty_points_model.dart';

class LoyaltyRepo {
  final Dio _dio = ApiClient.instance;

  Future<LoyaltyPointsModel> getLoyaltyPoints() async {
    final response = await _dio.get(ApiEndpoints.userLoyalty);
    return LoyaltyPointsModel.fromJson(response.data);
  }
}
