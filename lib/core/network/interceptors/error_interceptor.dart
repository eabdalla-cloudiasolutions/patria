// ✅ lib/core/network/interceptors/error_interceptor.dart
import 'package:dio/dio.dart';

import '../api_error_handler.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Use your ApiErrorHandler here!
    final message = ApiErrorHandler.handle(err);

    // Optionally log it
    // debugPrint('❌ API Error: $message');

    handler.next(err); // still propagate so repos can catch
  }
}
