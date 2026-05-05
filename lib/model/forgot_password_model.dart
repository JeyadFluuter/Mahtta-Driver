import 'dart:convert';

class ForgotPasswordModel {
  final String phone;

  ForgotPasswordModel({
    required this.phone,
  });

  factory ForgotPasswordModel.fromJson(String str) =>
      ForgotPasswordModel.fromMap(json.decode(str));

  factory ForgotPasswordModel.fromMap(Map<String, dynamic> json) =>
      ForgotPasswordModel(
        phone: json["phone"] ?? '',
      );

  Map<String, dynamic> toMap() => {
        "phone": phone,
      };
}
