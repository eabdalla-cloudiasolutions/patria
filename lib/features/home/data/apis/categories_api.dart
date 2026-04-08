import 'package:erb/core/network/api_client.dart';
import 'package:erb/core/network/api_endpoints.dart';
import 'package:erb/features/home/data/models/category_model.dart';

class CategoriesApi {
  Future<List<CategoryModel>> getCategories() async {
    final response = await ApiClient.instance.get(ApiEndpoints.categories);
    final List data = response.data as List;
    return data.map((e) => CategoryModel.fromJson(e)).toList();
  }
}
