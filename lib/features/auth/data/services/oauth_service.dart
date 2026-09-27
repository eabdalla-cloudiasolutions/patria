import 'package:dio/dio.dart';
import 'package:patria/core/network/api_client.dart';
import 'package:patria/core/network/api_endpoints.dart';
import 'package:patria/core/network/api_error_handler.dart';
import 'package:patria/core/services/notification_service.dart';
import 'package:patria/core/services/user_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class OAuthService {
  final _dio = ApiClient.instance;

  // ✅ Shared helper — register FCM token after any login
  Future<void> _registerFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await NotificationService().registerToken(fcmToken);
      }
    } catch (e) {
      // Silent fail — don't block login if token registration fails
    }
  }

  // ─── Google ───────────────────────────────────────────
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print('=== GoogleSignIn: starting signOut...');
      await GoogleSignIn.instance.signOut();
      print('=== GoogleSignIn: signOut done, starting authenticate...');

      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      print('=== GoogleSignIn: got user ${googleUser.email}');

      final response = await _dio.post(
        ApiEndpoints.oauthLogin,
        data: {
          'email': googleUser.email,
          'name': googleUser.displayName ?? '',
          'provider': 'google',
          'providerId': googleUser.id,
        },
      );

      final data = response.data;

      await UserService().saveUser(
        id: data['_id'] ?? '',
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        // ✅ The backend already knows the phone (e.g. saved on a previous
        // login) even though Google sign-in itself never provides one —
        // use it instead of wiping out the local cache with ''.
        phone: data['phone'] ?? '',
        role: data['role'] ?? '',
        token: data['token'] ?? '',
      );

      await _registerFcmToken(); // ✅

      return data;
    } on DioException catch (e) {
      print('=== GoogleSignIn DioException: ${e.message}');
      throw ApiErrorHandler.handle(e);
    } on GoogleSignInException catch (e) {
      print('=== GoogleSignInException code: ${e.code}, description: ${e.description}, details: ${e.details}');
      // ✅ The user just closed the account picker — not an error, so
      // silently return instead of surfacing a raw exception string.
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    } catch (e, stack) {
      print('=== GoogleSignIn unknown error: $e');
      print('=== Stack: $stack');
      rethrow;
    }
  }

  // ─── Apple ───────────────────────────────────────────
  Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final appleUserId = credential.userIdentifier ?? '';

      String fullName = '';
      if (credential.givenName != null || credential.familyName != null) {
        fullName =
            '${credential.givenName ?? ''} ${credential.familyName ?? ''}'
                .trim();
      }

      final response = await _dio.post(
        ApiEndpoints.oauthLogin,
        data: {
          'email': credential.email ?? '',
          'name': fullName,
          'provider': 'apple',
          'providerId': appleUserId,
          // ✅ Needed so the backend can exchange it for a refresh_token
          // with Apple and store it. That refresh_token is the only way
          // the backend can later call Apple's revoke endpoint on account
          // deletion — without it, Apple will never resend the real
          // email/name on a later sign-in with the same Apple ID, even
          // after the account is deleted on our side. See package docs on
          // AuthorizationCredentialAppleID.authorizationCode.
          'authorizationCode': credential.authorizationCode,
        },
      );

      final data = response.data;

      final savedEmail = data['email'] ?? '';
      final savedName =
          data['name'] ?? (fullName.isNotEmpty ? fullName : 'Apple User');

      await UserService().saveUser(
        id: data['_id'] ?? '',
        name: savedName,
        email: savedEmail,
        // ✅ Apple never provides a phone number either — use whatever the
        // backend already has on file for this account instead of ''.
        phone: data['phone'] ?? '',
        role: data['role'] ?? '',
        token: data['token'] ?? '',
      );

      await _registerFcmToken(); // ✅

      return data;
    } on DioException catch (e) {
      print('=== AppleSignIn DioException: ${e.response?.data}');
      throw ApiErrorHandler.handle(e);
    } on SignInWithAppleAuthorizationException catch (e) {
      print('=== AppleSignIn AuthorizationException code: ${e.code}');
      if (e.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // ─── Facebook ───────────────────────────────────────────
  Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      final loginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (loginResult.status != LoginStatus.success) return null;

      final userData = await FacebookAuth.instance.getUserData(
        fields: 'name,email,id',
      );

      final response = await _dio.post(
        ApiEndpoints.oauthLogin,
        data: {
          'email': userData['email'] ?? '',
          'name': userData['name'] ?? '',
          'provider': 'facebook',
          'providerId': userData['id'] ?? '',
        },
      );

      final data = response.data;

      await UserService().saveUser(
        id: data['_id'] ?? '',
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        // ✅ Same as Google/Apple — Facebook doesn't hand us a phone number,
        // but the backend may already have one on file for this account.
        phone: data['phone'] ?? '',
        role: data['role'] ?? '',
        token: data['token'] ?? '',
      );

      await _registerFcmToken(); // ✅

      return data;
    } on DioException catch (e) {
      throw ApiErrorHandler.handle(e);
    } catch (e) {
      rethrow;
    }
  }
}
