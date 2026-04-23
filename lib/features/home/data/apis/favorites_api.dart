import 'package:dio/dio.dart';
import 'package:erb/core/network/api_client.dart';
import 'package:erb/core/network/api_endpoints.dart';

class FavoritesApi {
  final Dio _dio = ApiClient.instance;

  Future<Response> getFavorites() async {
    return await _dio.get(ApiEndpoints.getFavorites);
  }

  // ✅ POST /users/favorites/{productId}  (no body needed)
  Future<Response> addToFavorites(String productId) async {
    return await _dio.post(ApiEndpoints.addToFavorites(productId));
  }

  // ✅ DELETE /users/favorites/{productId}
  Future<Response> removeFromFavorites(String productId) async {
    return await _dio.delete(ApiEndpoints.removeFromFavorites(productId));
  }
}
