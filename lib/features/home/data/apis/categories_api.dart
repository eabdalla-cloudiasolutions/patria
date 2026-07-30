import 'package:dio/dio.dart';
import 'package:patria/core/network/api_client.dart';
import 'package:patria/core/network/api_endpoints.dart';
import 'package:patria/core/network/api_error_handler.dart';
import 'package:patria/features/home/data/models/category_model.dart';

class CategoriesApi {
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.categories);
      final List data = response.data as List;
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiErrorHandler.handle(
        e,
      ); // throws formatted String like "Bad gateway..."
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }
}
