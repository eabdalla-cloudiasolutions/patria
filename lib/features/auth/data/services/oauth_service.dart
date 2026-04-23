import 'package:dio/dio.dart';
import 'package:erb/core/network/api_client.dart';
import 'package:erb/core/network/api_endpoints.dart';
import 'package:erb/core/network/api_error_handler.dart';
import 'package:erb/core/services/user_service.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class OAuthService {
  // ✅ Use existing ApiClient instead of new Dio instance
  final _dio = ApiClient.instance;

// ─── Google ───────────────────────────────────────────
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // ✅ v7+ API
      await GoogleSignIn.instance.signOut(); // force account picker

      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

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
        phone: '',
        role: data['role'] ?? '',
        token: data['token'] ?? '',
      );

      return data;
    } on DioException catch (e) {
      throw ApiErrorHandler.handle(e);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
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

      final response = await _dio.post(
        ApiEndpoints.oauthLogin,
        data: {
          'email': credential.email ?? '',
          'name': '${credential.givenName ?? ''} ${credential.familyName ?? ''}'
              .trim(),
          'provider': 'apple',
          'providerId': credential.userIdentifier ?? '',
        },
      );

      final data = response.data;

      await UserService().saveUser(
        id: data['_id'] ?? '',
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phone: '',
        role: data['role'] ?? '',
        token: data['token'] ?? '',
      );

      return data;
    } on DioException catch (e) {
      throw ApiErrorHandler.handle(e);
    } catch (e) {
      rethrow;
    }
  }

  // ─── Facebook ───────────────────────────────────────────
  Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      // ✅ Trigger Facebook login
      final loginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (loginResult.status != LoginStatus.success) return null;

      // ✅ Get user data
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

      // ✅ Save user
      await UserService().saveUser(
        id: data['_id'] ?? '',
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phone: '',
        role: data['role'] ?? '',
        token: data['token'] ?? '',
      );

      return data;
    } on DioException catch (e) {
      throw ApiErrorHandler.handle(e);
    } catch (e) {
      rethrow;
    }
  }
}
