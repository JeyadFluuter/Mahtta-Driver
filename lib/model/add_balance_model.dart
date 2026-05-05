import 'dart:convert';

class AddBalanceModel {
  final String code;

  AddBalanceModel({
    required this.code,
  });

  factory AddBalanceModel.fromJson(String str) =>
      AddBalanceModel.fromMap(json.decode(str));

  factory AddBalanceModel.fromMap(Map<String, dynamic> json) => AddBalanceModel(
        code: json["code"] ?? '',
      );

  Map<String, dynamic> toMap() => {
        "code": code,
      };
}
