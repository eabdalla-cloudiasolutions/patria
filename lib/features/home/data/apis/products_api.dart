import 'package:dio/dio.dart';
import 'package:patria/core/network/api_client.dart';
import 'package:patria/core/network/api_endpoints.dart';
import 'package:patria/core/services/user_service.dart';

class ProductsApi {
  final Dio _dio = ApiClient.instance;
  final UserService _userService = UserService();

  // Future<Response> getProducts({
  //   String? category,
  //   int page = 1,
  //   int limit = 20,
  // }) async {
  //   final queryParams = {
  //     'page': page,
  //     'limit': limit,
  //     if (category != null && category != 'All') 'category': category,
  //   };

  //   return await _dio.get(
  //     ApiEndpoints.products,
  //     queryParameters: queryParams,
  //   );
  // }

  Future<Response> getProductById(String id) async {
    return await _dio.get(ApiEndpoints.productById(id));
  }

  Future<Response> getProducts({
    String? category,
    String? search, // ✅ add this
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = {
      'page': page,
      'limit': limit,
      if (category != null && category != 'All') 'category': category,
      if (search != null && search.isNotEmpty) 'search': search, // ✅ add this
    };

    print('🔍 Query params sent: $queryParams');

    return await _dio.get(ApiEndpoints.products, queryParameters: queryParams);
  }

  Future<Response> getCategories() async {
    return await _dio.get(ApiEndpoints.categories);
  }

  Future<Response> getFeaturedProducts() async {
    return await _dio.get(ApiEndpoints.featured);
  }
}
