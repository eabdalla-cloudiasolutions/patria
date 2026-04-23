abstract class CheckoutPreviewEvent {}

class FetchCheckoutPreview extends CheckoutPreviewEvent {
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double couponDiscount;
  final int pointsToRedeem;

  FetchCheckoutPreview({
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    this.couponDiscount = 0,
    this.pointsToRedeem = 0,
  });
}
