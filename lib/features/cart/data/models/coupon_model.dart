// lib/features/cart/data/models/coupon_response.dart
class CouponResponse {
  final bool valid;
  final double discountAmount;
  final String? couponId;
  final String? code;
  final String? discountType;
  final double? discountValue;
  final String? message;

  CouponResponse({
    required this.valid,
    this.discountAmount = 0,
    this.couponId,
    this.code,
    this.discountType,
    this.discountValue,
    this.message,
  });

  factory CouponResponse.fromJson(Map<String, dynamic> json) {
    return CouponResponse(
      valid: json['valid'] ?? false,
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      couponId: json['couponId'],
      code: json['code'],
      discountType: json['discountType'],
      discountValue: json['discountValue']?.toDouble(),
      message: json['message'],
    );
  }
}
