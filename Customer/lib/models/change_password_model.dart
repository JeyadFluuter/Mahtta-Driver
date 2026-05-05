import 'dart:convert';

class ChangePasswordModel {
  final String oldPassword;
  final String password;
  final String passwordConfirmation;

  ChangePasswordModel({
    required this.oldPassword,
    required this.password,
    required this.passwordConfirmation,
  });

  factory ChangePasswordModel.fromJson(String str) =>
      ChangePasswordModel.fromMap(json.decode(str));

  factory ChangePasswordModel.fromMap(Map<String, dynamic> json) =>
      ChangePasswordModel(
        oldPassword: json["old_password"] ?? '',
        password: json["password"] ?? '',
        passwordConfirmation: json["password_confirmation"] ?? '',
      );

  Map<String, dynamic> toMap() => {
        "old_password": oldPassword,
        "password": password,
        "password_confirmation": passwordConfirmation,
      };
}
