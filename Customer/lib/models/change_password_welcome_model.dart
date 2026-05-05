import 'dart:convert';

class ChangePasswordWelcomeModel {
  final String phone;
  final String password;
  final String confirmPassword;

  ChangePasswordWelcomeModel({
    required this.phone,
    required this.password,
    required this.confirmPassword,
  });

  factory ChangePasswordWelcomeModel.fromJson(String str) =>
      ChangePasswordWelcomeModel.fromMap(json.decode(str));

  factory ChangePasswordWelcomeModel.fromMap(Map<String, dynamic> json) =>
      ChangePasswordWelcomeModel(
        phone: json["phone"] ?? '',
        password: json["password"] ?? '',
        confirmPassword: json["confirmPassword"] ?? '',
      );

  Map<String, dynamic> toMap() => {
        "phone": phone,
        "password": password,
        "confirmPassword": confirmPassword,
      };
}
