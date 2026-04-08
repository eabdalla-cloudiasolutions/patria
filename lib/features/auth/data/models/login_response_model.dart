class LoginResponseModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String token;

  LoginResponseModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.token,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'user',
      token: json['token'] ?? '',
    );
  }
}
