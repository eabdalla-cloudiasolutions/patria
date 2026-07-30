// ─── Bloc ─────────────────────────────────────────────
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patria/core/network/api_error_handler.dart';
import 'package:patria/features/account/data/apis/payment_api.dart';
import 'package:patria/features/account/presentation/manager/payments_card/payment_event.dart';
import 'package:patria/features/account/presentation/manager/payments_card/payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentApi _api = PaymentApi();

  PaymentBloc() : super(PaymentInitial()) {
    on<LoadPaymentMethods>(_onLoadPaymentMethods);
  }

  Future<void> _onLoadPaymentMethods(
    LoadPaymentMethods event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    try {
      final methods = await _api.getPaymentMethods();
      emit(PaymentLoaded(methods));
    } catch (e) {
      final errorMessage = ApiErrorHandler.handle(e as DioException);
      emit(PaymentError(errorMessage));
    }
  }
}
