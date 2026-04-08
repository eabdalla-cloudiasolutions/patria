// ✅ lib/core/network/interceptors/auth_interceptor.dart
import 'package:dio/dio.dart';

import '../../helpers/cache_helper.dart'; // your shared prefs / secure storage helper

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = CacheHelper.getToken(); // reads fresh every request
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}
