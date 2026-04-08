class LoyaltyPointsModel {
  final int points;
  final String tier;
  final String nextTier;
  final int pointsToNext;
  final double redeemableEGP;
  final int minRedemptionPoints;
  final double redeemRate;
  final double earnRate;

  LoyaltyPointsModel({
    required this.points,
    required this.tier,
    required this.nextTier,
    required this.pointsToNext,
    required this.redeemableEGP,
    required this.minRedemptionPoints,
    required this.redeemRate,
    required this.earnRate,
  });

  factory LoyaltyPointsModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyPointsModel(
      points: json['points'] ?? 0,
      tier: json['tier'] ?? 'Bronze',
      nextTier: json['nextTier'] ?? 'Silver',
      pointsToNext: json['pointsToNext'] ?? 500,
      redeemableEGP: (json['redeemableEGP'] ?? 0).toDouble(),
      minRedemptionPoints: json['minRedemptionPoints'] ?? 50,
      redeemRate: (json['redeemRate'] ?? 0.1).toDouble(),
      earnRate: (json['earnRate'] ?? 1).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'points': points,
      'tier': tier,
      'nextTier': nextTier,
      'pointsToNext': pointsToNext,
      'redeemableEGP': redeemableEGP,
      'minRedemptionPoints': minRedemptionPoints,
      'redeemRate': redeemRate,
      'earnRate': earnRate,
    };
  }
}
