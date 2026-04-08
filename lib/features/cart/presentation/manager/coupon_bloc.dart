// lib/features/cart/presentation/bloc/coupon_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:erb/features/cart/data/repos/coupon_repository.dart';
import 'package:erb/features/cart/presentation/manager/coupon_event.dart';
import 'package:erb/features/cart/presentation/manager/coupon_state.dart';

class CouponBloc extends Bloc<CouponEvent, CouponState> {
  final CouponRepository repository;

  CouponBloc({required this.repository}) : super(CouponInitial()) {
    on<ApplyCoupon>(_onApplyCoupon);
    on<RemoveCoupon>(_onRemoveCoupon);
  }

  Future<void> _onApplyCoupon(
      ApplyCoupon event, Emitter<CouponState> emit) async {
    emit(CouponLoading());
    try {
      final response = await repository.applyCoupon(event.code, event.subtotal);
      if (response.valid) {
        emit(CouponApplied(response));
      } else {
        emit(CouponError(response.message ?? 'Invalid coupon'));
      }
    } catch (e) {
      emit(CouponError(e.toString()));
    }
  }

  void _onRemoveCoupon(RemoveCoupon event, Emitter<CouponState> emit) {
    emit(CouponRemoved());
    emit(CouponInitial()); // optional: clear state after removal
  }
}
