import 'package:dio/dio.dart';
import 'package:erb/core/network/api_error_handler.dart';
import 'package:erb/features/home/data/apis/favorites_api.dart';
import 'package:erb/features/home/data/models/favorite_product_model.dart';

class FavoritesRepo {
  final FavoritesApi _api = FavoritesApi();

  Future<List<FavoriteProductModel>> getFavorites() async {
    try {
      final response = await _api.getFavorites();
      final List<dynamic> data =
          response.data is List ? response.data : (response.data['data'] ?? []);
      return data.map((json) => FavoriteProductModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<void> addToFavorites(String productId) async {
    try {
      await _api.addToFavorites(productId);
    } on DioException catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<void> removeFromFavorites(String productId) async {
    try {
      await _api.removeFromFavorites(productId);
    } on DioException catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
