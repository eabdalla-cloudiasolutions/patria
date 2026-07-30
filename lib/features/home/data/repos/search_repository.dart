import 'package:dio/dio.dart';
import 'package:patria/core/network/api_error_handler.dart';
import 'package:patria/features/home/data/apis/search_api.dart';

class SearchRepository {
  final SearchApi _api = SearchApi();

  Future<void> logSearch(String query) async {
    try {
      await _api.logSearch(query);
    } on DioException catch (e) {
      // Silent fail — don't block user if logging fails
      print('Search log failed: ${ApiErrorHandler.handle(e)}');
    } catch (_) {}
  }

  Future<List<String>> getSearchHistory() async {
    try {
      return await _api.getSearchHistory(limit: 5);
    } on DioException catch (e) {
      print('Search history failed: ${ApiErrorHandler.handle(e)}');
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<String>> getTrending() async {
    try {
      return await _api.getTrending(limit: 5, days: 7);
    } on DioException catch (e) {
      print('Trending failed: ${ApiErrorHandler.handle(e)}');
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> clearHistory() async {
    try {
      await _api.clearHistory();
    } on DioException catch (e) {
      print('Clear history failed: ${ApiErrorHandler.handle(e)}');
    } catch (_) {}
  }
}
