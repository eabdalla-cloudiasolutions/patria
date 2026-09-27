// lib/features/cart/presentation/bloc/coupon_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:patria/core/network/api_error_handler.dart';
import 'package:patria/features/cart/data/repos/coupon_repository.dart';
import 'package:patria/features/cart/presentation/manager/coupon_event.dart';
import 'package:patria/features/cart/presentation/manager/coupon_state.dart';

class CouponBloc extends Bloc<CouponEvent, CouponState> {
  final CouponRepository repository;

  CouponBloc({required this.repository}) : super(CouponInitial()) {
    on<ApplyCoupon>(_onApplyCoupon);
    on<RemoveCoupon>(_onRemoveCoupon);
  }

  Future<void> _onApplyCoupon(
    ApplyCoupon event,
    Emitter<CouponState> emit,
  ) async {
    emit(CouponLoading());
    try {
      final response = await repository.applyCoupon(event.code, event.subtotal);
      if (response.valid) {
        emit(CouponApplied(response));
      } else {
        // Invalid coupon from API (valid=false with message)
        emit(CouponError(response.message ?? 'Invalid coupon'));
      }
    } catch (e) {
      // DioException or other errors
      final errorMessage = e is DioException ? ApiErrorHandler.handle(e) : e.toString();
      emit(CouponError(errorMessage));
    }
  }

  void _onRemoveCoupon(RemoveCoupon event, Emitter<CouponState> emit) {
    emit(CouponRemoved());
    emit(CouponInitial());
  }
}
