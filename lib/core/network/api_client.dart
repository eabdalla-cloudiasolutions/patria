import 'package:dio/dio.dart';
import 'package:patria/core/network/api_endpoints.dart';
import 'package:patria/core/network/interceptors/error_interceptor.dart';
import 'package:patria/core/services/user_service.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiClient {
  static final Dio instance =
      Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        )
        ..interceptors.add(
          PrettyDioLogger(
            requestHeader: true,
            requestBody: true,
            responseBody: true,
            responseHeader: false,
            error: true,
            compact: false,
          ),
        )
        // ✅ Add once here — applies to ALL requests automatically
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final token = await UserService().getUserToken();
              if (token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              handler.next(options);
            },
          ),
        )
        ..interceptors.add(ErrorInterceptor()); // ✅ ADD THIS LINE
}
