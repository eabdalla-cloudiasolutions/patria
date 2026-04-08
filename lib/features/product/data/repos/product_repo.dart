// lib/features/product/data/repos/product_repo.dart
import 'package:dio/dio.dart';
import 'package:erb/core/network/api_error_handler.dart';
import 'package:erb/features/home/data/models/product_model.dart';

import '../apis/product_api.dart';

class ProductRepo {
  final ProductApi _api = ProductApi();

  Future<List<ProductModel>> getProducts() async {
    try {
      final data = await _api.getProducts();
      return data.map((e) => ProductModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiErrorHandler.handle(e); // throws String message
    }
  }

  Future<ProductModel> getProductById(String id) async {
    try {
      final data = await _api.getProductById(id);
      return ProductModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
