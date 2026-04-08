// lib/features/cart/presentation/bloc/coupon_state.dart
import 'package:equatable/equatable.dart';
import 'package:erb/features/cart/data/models/coupon_model.dart';

abstract class CouponState extends Equatable {
  const CouponState();
  @override
  List<Object?> get props => [];
}

class CouponInitial extends CouponState {}

class CouponLoading extends CouponState {}

class CouponApplied extends CouponState {
  final CouponResponse coupon;
  const CouponApplied(this.coupon);
  @override
  List<Object?> get props => [coupon];
}

class CouponRemoved extends CouponState {}

class CouponError extends CouponState {
  final String message;
  const CouponError(this.message);
  @override
  List<Object?> get props => [message];
}
