import 'package:patria/core/network/api_client.dart';
import 'package:patria/core/network/api_endpoints.dart';

class SearchApi {
  Future<void> logSearch(String query) async {
    await ApiClient.instance.post(
      ApiEndpoints.logSearchQuery,
      data: {'query': query},
    );
  }

  Future<List<String>> getSearchHistory({int limit = 5}) async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.searchHistory,
      queryParameters: {'limit': limit},
    );
    final List data = response.data as List;
    return data
        .map((e) => e['query']?.toString() ?? '')
        .where((q) => q.isNotEmpty)
        .toList();
  }

  Future<List<String>> getTrending({int limit = 5, int days = 7}) async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.searchTrending,
      queryParameters: {'limit': limit, 'days': days},
    );
    final List data = response.data as List;
    return data
        .map((e) => e['query']?.toString() ?? '')
        .where((q) => q.isNotEmpty)
        .toList();
  }

  Future<void> clearHistory() async {
    await ApiClient.instance.delete(ApiEndpoints.clearSearchHistory);
  }
}
