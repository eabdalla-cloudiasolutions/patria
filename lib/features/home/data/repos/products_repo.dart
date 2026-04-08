import 'package:dio/dio.dart';
import 'package:erb/core/network/api_error_handler.dart';
import 'package:erb/features/home/data/apis/products_api.dart';
import 'package:erb/features/home/data/models/product_model.dart';

class ProductsRepo {
  final ProductsApi _api = ProductsApi();

  Future<List<ProductModel>> getProducts(
      {String? category, String? search}) async {
    try {
      final response =
          await _api.getProducts(category: category, search: search);

      if (response.data['data'] != null) {
        final List<dynamic> productsData = response.data['data'];
        return productsData.map((json) => ProductModel.fromJson(json)).toList();
      } else if (response.data['products'] != null) {
        final List<dynamic> productsData = response.data['products'];
        return productsData.map((json) => ProductModel.fromJson(json)).toList();
      }

      return [];
    } on DioException catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _api.getCategories();

      if (response.data['data'] != null) {
        final List<dynamic> categoriesData = response.data['data'];
        return categoriesData
            .map((json) => CategoryModel.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
