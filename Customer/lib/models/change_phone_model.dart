import 'dart:convert';

class ChangePhoneModel {
  final String phone;

  ChangePhoneModel({
    required this.phone,
  });

  factory ChangePhoneModel.fromJson(String str) =>
      ChangePhoneModel.fromMap(json.decode(str));
  factory ChangePhoneModel.fromMap(Map<String, dynamic> json) =>
      ChangePhoneModel(
        phone: json["phone"] ?? '',
      );
  Map<String, dynamic> toMap() => {
        "phone": phone,
      };
}
