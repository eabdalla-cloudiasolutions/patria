// lib/features/cart/presentation/bloc/coupon_event.dart
import 'package:equatable/equatable.dart';

abstract class CouponEvent extends Equatable {
  const CouponEvent();
  @override
  List<Object?> get props => [];
}

class ApplyCoupon extends CouponEvent {
  final String code;
  final double subtotal;
  const ApplyCoupon(this.code, this.subtotal);
  @override
  List<Object?> get props => [code, subtotal];
}

class RemoveCoupon extends CouponEvent {
  const RemoveCoupon();
}
