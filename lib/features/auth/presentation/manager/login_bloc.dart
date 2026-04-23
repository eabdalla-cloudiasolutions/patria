import 'package:dio/dio.dart';
import 'package:erb/core/network/api_error_handler.dart';
import 'package:erb/core/services/user_service.dart'; // 👈 Add this import
import 'package:erb/features/auth/data/models/login_request_model.dart';
import 'package:erb/features/auth/data/repos/auth_repo.dart';
import 'package:erb/features/auth/presentation/manager/login_event.dart';
import 'package:erb/features/auth/presentation/manager/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepo _authRepo;

  LoginBloc(this._authRepo) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final response = await _authRepo.login(LoginRequestModel(
        email: event.email,
        password: event.password,
      ));

      // 👇 Save user data using UserService
      final userService = UserService();
      await userService.saveUser(
        id: response.id,
        name: response.name,
        email: response.email,
        phone: response.phone,
        role: response.role,
        token: response.token,
      );

      emit(LoginSuccess(response));
    } catch (e) {
      final errorMessage = ApiErrorHandler.handle(e as DioException);
      emit(LoginFailure(errorMessage));
    }
  }
}
