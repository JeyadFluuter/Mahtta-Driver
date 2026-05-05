import 'dart:convert';

class OtpChangePhoneModel {
  final String phone;
  final String otp;

  OtpChangePhoneModel({required this.phone, required this.otp});

  factory OtpChangePhoneModel.fromJson(String str) =>
      OtpChangePhoneModel.fromMap(json.decode(str));

  factory OtpChangePhoneModel.fromMap(Map<String, dynamic> json) =>
      OtpChangePhoneModel(phone: json["phone"] ?? '', otp: json["otp"]);

  Map<String, dynamic> toMap() => {
        "phone": phone,
        "otp": otp,
      };
}
