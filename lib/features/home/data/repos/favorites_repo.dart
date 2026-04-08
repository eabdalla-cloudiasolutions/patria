import 'package:dio/dio.dart';
import 'package:erb/core/network/api_client.dart';
import 'package:erb/features/home/data/models/favorite_product_model.dart';

class FavoritesRepo {
  final Dio _dio = ApiClient.instance;

  Future<List<FavoriteProductModel>> getFavorites() async {
    try {
      final response = await _dio.get('/users/favorites');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data =
            response.data is List ? response.data : response.data['data'] ?? [];

        return data.map((json) => FavoriteProductModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return [];
      }
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> addToFavorites(String productId) async {
    try {
      await _dio.post('/users/favorites/$productId');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to add to favorites');
    }
  }

  Future<void> removeFromFavorites(String productId) async {
    try {
      await _dio.delete('/users/favorites/$productId');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to remove from favorites');
    }
  }
}
