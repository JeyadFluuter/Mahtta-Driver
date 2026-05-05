import 'dart:convert';

class UpdateProfile {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? city;

  UpdateProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.city,
  });

  factory UpdateProfile.fromJson(String str) =>
      UpdateProfile.fromMap(json.decode(str));

  /// بناء الكائن من خريطة (Map)
  factory UpdateProfile.fromMap(Map<String, dynamic> json) => UpdateProfile(
        firstName: json["first_name"] ?? '',
        lastName: json["last_name"] ?? '',
        city: json["city"] ?? '',
        email: json["email"] ?? '',
      );

  /// تحويل الكائن إلى خريطة (Map)
  Map<String, dynamic> toMap() => {
        "first_name": firstName,
        "last_name": lastName,
        "city": city,
        "email": email,
      };
}
