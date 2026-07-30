abstract class CheckoutPreviewEvent {
  const CheckoutPreviewEvent();
}

class FetchCheckoutPreview extends CheckoutPreviewEvent {
  final double subtotal;
  final double deliveryFee;
  final double couponDiscount;
  final int pointsToRedeem;

  const FetchCheckoutPreview({
    required this.subtotal,
    required this.deliveryFee,
    this.couponDiscount = 0,
    this.pointsToRedeem = 0,
  });
}
