import 'package:erb/features/auth/data/models/login_response_model.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final LoginResponseModel response;
  LoginSuccess(this.response);
}

class LoginFailure extends LoginState {
  final String error;
  LoginFailure(this.error);
}
