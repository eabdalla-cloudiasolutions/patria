class CheckoutPreviewModel {
  final int pointsBalance;
  final double redeemableEGP;
  final int minRedeemPoints;
  final bool canRedeem;
  final int maxPointsRedeemableThisOrder;
  final int pointsToRedeemApplied;
  final double pointsDiscountEGP;
  final CheckoutTotals totals;
  final int pointsEarnedIfOrderCompleted;
  final RedeemRule redeemRule;
  final EarnRule earnRule;

  const CheckoutPreviewModel({
    required this.pointsBalance,
    required this.redeemableEGP,
    required this.minRedeemPoints,
    required this.canRedeem,
    required this.maxPointsRedeemableThisOrder,
    required this.pointsToRedeemApplied,
    required this.pointsDiscountEGP,
    required this.totals,
    required this.pointsEarnedIfOrderCompleted,
    required this.redeemRule,
    required this.earnRule,
  });

  factory CheckoutPreviewModel.fromJson(Map<String, dynamic> json) {
    return CheckoutPreviewModel(
      pointsBalance: json['pointsBalance'] ?? 0,
      redeemableEGP: (json['redeemableEGP'] ?? 0).toDouble(),
      minRedeemPoints: json['minRedeemPoints'] ?? 50,
      canRedeem: json['canRedeem'] ?? false,
      maxPointsRedeemableThisOrder: json['maxPointsRedeemableThisOrder'] ?? 0,
      pointsToRedeemApplied: json['pointsToRedeemApplied'] ?? 0,
      pointsDiscountEGP: (json['pointsDiscountEGP'] ?? 0).toDouble(),
      totals: CheckoutTotals.fromJson(json['totals']),
      pointsEarnedIfOrderCompleted: json['pointsEarnedIfOrderCompleted'] ?? 0,
      redeemRule: RedeemRule.fromJson(json['rules']['redeem']),
      earnRule: EarnRule.fromJson(json['rules']['earn']),
    );
  }
}

class CheckoutTotals {
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double couponDiscount;
  final double totalBeforePoints;
  final double totalAfterPoints;

  const CheckoutTotals({
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.couponDiscount,
    required this.totalBeforePoints,
    required this.totalAfterPoints,
  });

  factory CheckoutTotals.fromJson(Map<String, dynamic> json) {
    return CheckoutTotals(
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      serviceFee: (json['serviceFee'] ?? 0).toDouble(),
      couponDiscount: (json['couponDiscount'] ?? 0).toDouble(),
      totalBeforePoints: (json['totalBeforePoints'] ?? 0).toDouble(),
      totalAfterPoints: (json['totalAfterPoints'] ?? 0).toDouble(),
    );
  }
}

class RedeemRule {
  final int pointsPerEgp;
  final double egpPerPoint;
  final String displayLabel;

  const RedeemRule({
    required this.pointsPerEgp,
    required this.egpPerPoint,
    required this.displayLabel,
  });

  factory RedeemRule.fromJson(Map<String, dynamic> json) {
    return RedeemRule(
      pointsPerEgp: json['pointsPerEgp'] ?? 10,
      egpPerPoint: (json['egpPerPoint'] ?? 0.1).toDouble(),
      displayLabel: json['displayLabel'] ?? '',
    );
  }
}

class EarnRule {
  final int egpPerPointEarned;
  final String creditedWhen;

  const EarnRule({
    required this.egpPerPointEarned,
    required this.creditedWhen,
  });

  factory EarnRule.fromJson(Map<String, dynamic> json) {
    return EarnRule(
      egpPerPointEarned: json['egpPerPointEarned'] ?? 10,
      creditedWhen: json['creditedWhen'] ?? '',
    );
  }
}
