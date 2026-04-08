class PaymentMethodModel {
  final String id;
  final String cardType;
  final String last4;
  final String cardholderName;
  final String expiryMonth;
  final String expiryYear;
  final bool isDefault;

  PaymentMethodModel({
    required this.id,
    required this.cardType,
    required this.last4,
    required this.cardholderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.isDefault,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      PaymentMethodModel(
        id: json['_id']?.toString() ?? '',
        cardType: json['cardType']?.toString() ?? '',
        last4: json['last4']?.toString() ?? '',
        cardholderName: json['cardholderName']?.toString() ?? '',
        expiryMonth: json['expiryMonth']?.toString() ?? '',
        expiryYear: json['expiryYear']?.toString() ?? '',
        isDefault: json['isDefault'] ?? false,
      );
}
