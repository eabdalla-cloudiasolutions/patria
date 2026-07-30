// lib/features/cart/data/repositories/coupon_repository.dart
import 'package:patria/features/cart/data/apis/coupon_api.dart';
import 'package:patria/features/cart/data/models/coupon_model.dart';

class CouponRepository {
  final CouponApi api;

  CouponRepository({required this.api});

  Future<CouponResponse> applyCoupon(String code, double subtotal) async {
    final json = await api.validateCoupon(code, subtotal);
    return CouponResponse.fromJson(json);
  }
}
