import 'dart:io';

import 'package:dio/dio.dart';
import 'package:erb/core/network/api_client.dart';
import 'package:erb/core/network/api_endpoints.dart';
import 'package:erb/core/services/user_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final Dio _dio = ApiClient.instance;
  static const String _mobileRegisterKey = String.fromEnvironment(
    'MOBILE_REGISTER_KEY',
    defaultValue: '',
  );

  /// Register FCM token for the logged-in user
  Future<void> registerToken(String fcmToken) async {
    print('FCMgg$fcmToken');
    final userId = await UserService().getUserId();
    final platform =
        Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : 'unknown');

    final headers = <String, dynamic>{};
    if (_mobileRegisterKey.isNotEmpty) {
      headers['X-Mobile-Register-Key'] = _mobileRegisterKey;
    }

    try {
      await _dio.post(
        ApiEndpoints.registerDeviceToken,
        options: Options(headers: headers),
        data: {
          'token': fcmToken,
          'platform': platform,
          if (userId.isNotEmpty) 'userId': userId,
        },
      );
    } on DioException catch (e) {
      // You can use your ApiErrorHandler here
      throw Exception('Failed to register token: ${e.message}');
    }
  }

  /// Unregister token on logout
  Future<void> unregisterToken() async {
    final currentToken = await FirebaseMessaging.instance.getToken();
    if (currentToken == null || currentToken.isEmpty) {
      return;
    }

    final headers = <String, dynamic>{};
    if (_mobileRegisterKey.isNotEmpty) {
      headers['X-Mobile-Register-Key'] = _mobileRegisterKey;
    }

    try {
      await _dio.delete(
        ApiEndpoints.unregisterDeviceToken,
        options: Options(headers: headers),
        data: {'token': currentToken},
      );
    } on DioException catch (e) {
      // Log but don't throw – logout should continue
      print('Unregister failed: ${e.message}');
    }
  }
}
