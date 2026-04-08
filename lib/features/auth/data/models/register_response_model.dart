class RegisterResponseModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String token;

  RegisterResponseModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) =>
      RegisterResponseModel(
        id: json['_id']?.toString() ?? '', // ✅ API returns _id not id
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        role: json['role']?.toString() ?? '',
        token: json['token']?.toString() ?? '', // ✅ API returns token directly
      );
}
