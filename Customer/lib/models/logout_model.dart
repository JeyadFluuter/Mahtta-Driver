import 'dart:convert';

class LogoutModel {
  final String token;

  LogoutModel({
    required this.token,
  });

  factory LogoutModel.fromJson(String str) =>
      LogoutModel.fromMap(json.decode(str));

  factory LogoutModel.fromMap(Map<String, dynamic> json) => LogoutModel(
        token: json["token"] ?? '',
      );

  Map<String, dynamic> toMap() => {
        "token": token,
      };
}
