class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String token;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.token,
  });

  // Static empty user
  static final UserModel empty = const UserModel(
    id: '',
    name: '',
    email: '',
    phone: '',
    role: '',
    token: '',
  );

  bool get isLoggedIn => token.isNotEmpty;

  // Copy with method for updates
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}
