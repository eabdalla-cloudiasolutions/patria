import 'package:patria/features/auth/data/apis/auth_api.dart';
import 'package:patria/features/auth/data/models/login_request_model.dart';
import 'package:patria/features/auth/data/models/login_response_model.dart';
import 'package:patria/features/auth/data/models/register_request_model.dart';
import 'package:patria/features/auth/data/models/register_response_model.dart';

class AuthRepo {
  final AuthApi _api = AuthApi();

  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    final response = await _api.register(request);
    return RegisterResponseModel.fromJson(response.data);
  }

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final response = await _api.login(request);
    return LoginResponseModel.fromJson(response.data);
  }
}
