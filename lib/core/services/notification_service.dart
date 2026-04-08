import 'package:dio/dio.dart';
import 'package:erb/core/network/api_client.dart';
import 'package:erb/core/network/api_endpoints.dart';

class NotificationService {
  final Dio _dio = ApiClient.instance;

  /// Register FCM token for the logged-in user
  Future<void> registerToken(String fcmToken) async {
    try {
      await _dio.post(
        ApiEndpoints.registerDeviceToken,
        data: {
          'token': fcmToken,
          // If backend expects platform, add:
          // 'platform': Platform.isIOS ? 'ios' : 'android',
        },
      );
    } on DioException catch (e) {
      // You can use your ApiErrorHandler here
      throw Exception('Failed to register token: ${e.message}');
    }
  }

  /// Unregister token on logout
  Future<void> unregisterToken() async {
    try {
      await _dio.delete(ApiEndpoints.unregisterDeviceToken);
    } on DioException catch (e) {
      // Log but don't throw – logout should continue
      print('Unregister failed: ${e.message}');
    }
  }
}
