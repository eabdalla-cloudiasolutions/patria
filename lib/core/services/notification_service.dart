import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:patria/core/network/api_client.dart';
import 'package:patria/core/network/api_endpoints.dart';
import 'package:patria/core/notifications/local_notifications_service.dart';
import 'package:patria/core/notifications/notification_navigation.dart';
import 'package:patria/core/routing/routes.dart';
import 'package:patria/firebase_options.dart';

/// Background / terminated handler — MUST be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // The OS shows the notification automatically when a `notification` payload exists.
  debugPrint('BG message: ${message.messageId}');
}

class NotificationService {
  final Dio _dio = ApiClient.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final LocalNotificationsService _local = LocalNotificationsService();

  /// Call once from main() after Firebase.initializeApp().
  Future<void> init() async {
    // Ask for notification permission (iOS + Android 13+).
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Prepare the local channel + tap callback (foreground display).
    await _local.init(onTap: _handlePayloadTap);

    // iOS: also show alert/badge/sound while the app is in the foreground.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // FOREGROUND: FCM shows nothing by itself, so we display it.
    FirebaseMessaging.onMessage.listen(_local.show);

    // BACKGROUND (not terminated): user tapped the system notification.
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _navigate(m.data));

    // TERMINATED: app was opened by tapping a notification (cold start).
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _navigate(initial.data);

    final token = await _messaging.getToken();
    debugPrint('FCM token: $token');
  }

  void _handlePayloadTap(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      _navigate(jsonDecode(payload) as Map<String, dynamic>);
    } catch (_) {}
  }

  /// Where a notification tap should send the user.
  /// Adjust the data keys to match what your backend sends in `data`.
  void _navigate(Map<String, dynamic> data) {
    final orderId = (data['orderId'] ?? data['order_id'])?.toString();
    if (orderId != null && orderId.isNotEmpty) {
      navigatorKey.currentState?.pushNamed(
        Routes.trackOrder,
        arguments: {
          'orderId': orderId,
          'orderNumber':
              (data['orderNumber'] ?? data['order_number'])?.toString() ?? '',
          'estimatedArrival':
              data['estimatedArrival']?.toString() ?? '30 min - 60 min',
          'currentStep':
              int.tryParse(data['currentStep']?.toString() ?? '') ?? 0,
        },
      );
    }
  }

  /// Register this device's FCM token with the backend.
  /// Call after a successful login and whenever the token refreshes.
  Future<void> registerToken(String fcmToken) async {
    final platform = Platform.isIOS
        ? 'ios'
        : (Platform.isAndroid ? 'android' : 'unknown');
    try {
      await _dio.post(
        ApiEndpoints.registerDeviceToken,
        data: {'token': fcmToken, 'platform': platform},
      );
      debugPrint('FCM token registered with backend');
    } on DioException catch (e) {
      debugPrint(
        'Register token failed: ${e.response?.statusCode} ${e.message}',
      );
    }
  }

  /// Unregister this device's token. Call on logout, while still authenticated.
  Future<void> unregisterToken() async {
    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) return;
    try {
      await _dio.delete(
        ApiEndpoints.unregisterDeviceToken,
        data: {'token': token},
      );
      debugPrint('FCM token unregistered');
    } on DioException catch (e) {
      debugPrint('Unregister token failed: ${e.message}');
    }
  }
}
