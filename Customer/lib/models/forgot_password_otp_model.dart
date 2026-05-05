import 'dart:convert';

List<ForgetpasswordotpVerify> warningFromJson(String str) =>
    List<ForgetpasswordotpVerify>.from(
      json.decode(str).map(
            (x) => ForgetpasswordotpVerify.fromJson(x),
          ),
    );
String warningToJson(List<ForgetpasswordotpVerify> data) => json.encode(
      List<dynamic>.from(
        data.map((x) => x.tojson()),
      ),
    );

class ForgetpasswordotpVerify {
  String? phone;
  String otpCode;

  ForgetpasswordotpVerify({
    this.phone,
    required this.otpCode,
  });
  factory ForgetpasswordotpVerify.fromJson(Map<String, dynamic> json) =>
      ForgetpasswordotpVerify(
        phone: json["phone"],
        otpCode: json[" otp_code"],
      );

  Map<String, dynamic> tojson() => {
        'phone': phone,
        'otp_code': otpCode,
      };
}
