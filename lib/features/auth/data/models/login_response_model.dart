class LoginResponseModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String token;
  final bool isPhoneVerified; // ← new
  final int loyaltyPoints; // optional
  final String tier; // optional

  LoginResponseModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.token,
    required this.isPhoneVerified,
    this.loyaltyPoints = 0,
    this.tier = '',
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'user',
      token: json['token'] ?? '',
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
      tier: json['tier'] ?? '',
    );
  }
}
