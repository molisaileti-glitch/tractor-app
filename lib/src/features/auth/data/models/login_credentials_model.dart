class LoginCredentialsModel {
  const LoginCredentialsModel({
    required this.phoneOrEmail,
    required this.password,
  });

  factory LoginCredentialsModel.fromJson(Map<String, Object?> json) {
    return LoginCredentialsModel(
      phoneOrEmail: json['phoneOrEmail']! as String,
      password: json['password']! as String,
    );
  }

  final String phoneOrEmail;
  final String password;

  Map<String, Object?> toJson() {
    return {'phoneOrEmail': phoneOrEmail, 'password': password};
  }
}
