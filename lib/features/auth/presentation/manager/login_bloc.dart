import 'package:dio/dio.dart';
import 'package:patria/core/network/api_error_handler.dart';
import 'package:patria/core/services/user_service.dart';
import 'package:patria/features/auth/data/models/login_request_model.dart';
import 'package:patria/features/auth/data/repos/auth_repo.dart';
import 'package:patria/features/auth/presentation/manager/login_event.dart';
import 'package:patria/features/auth/presentation/manager/login_state.dart';
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
      final response = await _authRepo.login(
        LoginRequestModel(email: event.email, password: event.password),
      );

      // Save user data using UserService
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
      // Check if it's a DioException with status code 403
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 403) {
          // Extract phone number from response data (if available)
          final data = e.response?.data;
          String? phoneNumber;
          if (data is Map<String, dynamic>) {
            phoneNumber = data['phone'] as String?;
          }
          final errorMessage = ApiErrorHandler.handle(e);
          emit(
            LoginFailure(
              errorMessage,
              statusCode: statusCode,
              phoneNumber: phoneNumber,
            ),
          );
          return;
        }
      }
      // For other errors (network, 4xx, 5xx, etc.)
      final errorMessage = e is DioException ? ApiErrorHandler.handle(e) : e.toString();
      emit(LoginFailure(errorMessage));
    }
  }
}
