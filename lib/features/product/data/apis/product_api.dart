// lib/features/product/data/apis/product_api.dart
import 'package:dio/dio.dart';
import 'package:erb/core/network/api_client.dart';
import 'package:erb/core/network/api_endpoints.dart';

class ProductApi {
  final Dio _dio = ApiClient.instance;

  Future<List<dynamic>> getProducts() async {
    final response = await _dio.get(ApiEndpoints.products);
    return response.data['data']; // adjust to your API response shape
  }

  Future<Map<String, dynamic>> getProductById(String id) async {
    final response = await _dio.get(ApiEndpoints.productById(id));
    return response.data['data'];
  }
}
