import 'package:dio/dio.dart';
import 'package:erb/core/network/api_client.dart';
import 'package:erb/core/network/api_endpoints.dart';
import 'package:erb/features/auth/data/models/login_request_model.dart';
import 'package:erb/features/auth/data/models/register_request_model.dart';

class AuthApi {
  final Dio _dio = ApiClient.instance;

  Future<Response> register(RegisterRequestModel request) async {
    return await _dio.post(ApiEndpoints.register, data: request.toJson());
  }

  Future<Response> login(LoginRequestModel request) async {
    return await _dio.post(ApiEndpoints.login, data: request.toJson());
  }

  // ✅ Send OTP via WhatsApp
  Future<Response> sendVerification(String phone) async {
    return await _dio.post(
      ApiEndpoints.sendVerification,
      data: {'phone': phone},
    );
  }

  // ✅ Verify OTP
  Future<Response> verifyOtp(String phone, String code) async {
    return await _dio.post(
      ApiEndpoints.verifyOtp,
      data: {
        'phone': phone,
        'code': code,
      },
    );
  }

  Future<Response> updateProfile({
    required String name,
    required String phone,
    String? dateOfBirth,
  }) async {
    return await _dio.put(
      ApiEndpoints.updateProfile,
      data: {
        'name': name,
        'phone': phone,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth, // ✅ optional
      },
    );
  }

  Future<Response> forgotPassword(String phone) async {
    return await _dio.post(
      ApiEndpoints.forgotPassword,
      data: {'phone': phone},
    );
  }

  Future<Response> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    return await _dio.post(
      ApiEndpoints.resetPassword,
      data: {
        'phone': phone,
        'code': code,
        'newPassword': newPassword,
      },
    );
  }
}
