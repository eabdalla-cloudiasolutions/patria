import 'package:dio/dio.dart';
import 'package:erb/core/network/api_error_handler.dart';
import 'package:erb/features/auth/data/models/register_request_model.dart';
import 'package:erb/features/auth/data/repos/auth_repo.dart';
import 'package:erb/features/auth/presentation/manager/register_event.dart';
import 'package:erb/features/auth/presentation/manager/register_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepo _authRepo;

  RegisterBloc(this._authRepo) : super(RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());
    try {
      await _authRepo.register(RegisterRequestModel(
        name: event.name,
        email: event.email,
        password: event.password,
        phone: event.phone,
        role: event.role,
      ));
      emit(RegisterSuccess());
    } catch (e) {
      final errorMessage = ApiErrorHandler.handle(e as DioException);
      emit(RegisterFailure(errorMessage));
    }
  }
}
