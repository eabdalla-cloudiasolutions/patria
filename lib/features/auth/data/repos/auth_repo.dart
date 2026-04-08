import 'package:dio/dio.dart';
import 'package:erb/core/network/api_error_handler.dart';
import 'package:erb/features/auth/data/apis/auth_api.dart';
import 'package:erb/features/auth/data/models/login_request_model.dart';
import 'package:erb/features/auth/data/models/login_response_model.dart';
import 'package:erb/features/auth/data/models/register_request_model.dart';
import 'package:erb/features/auth/data/models/register_response_model.dart';

class AuthRepo {
  final AuthApi _api = AuthApi();

  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await _api.register(request);
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      return RegisterResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('Dio error type: ${e.type}');
      print('Dio error message: ${e.message}');
      print('Dio response: ${e.response}');
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _api.login(request);
      print('Login response status: ${response.statusCode}');
      print('Login response data: ${response.data}');
      return LoginResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('Login error type: ${e.type}');
      print('Login error message: ${e.message}');
      throw ApiErrorHandler.handle(e);
    }
  }
}
