import 'dart:convert';

import 'package:biadgo/constants/apiUrl.dart';

class LoginResponse {
  final Data data;
  final int error;
  final String message;

  LoginResponse({
    required this.data,
    required this.error,
    required this.message,
  });

  factory LoginResponse.fromJson(String str) =>
      LoginResponse.fromMap(json.decode(str));

  factory LoginResponse.fromMap(Map<String, dynamic> json) => LoginResponse(
        data: Data.fromMap(json["data"]),
        error: json["error"] ?? 0,
        message: json["message"] ?? '',
      );

  Map<String, dynamic> toMap() => {
        "data": data.toMap(),
        "error": error,
        "message": message,
      };
}

class Data {
  final Customer customer;
  final String token;
  final String accessExpires;
  final String refreshToken;
  final String refreshExpires;

  Data({
    required this.customer,
    required this.token,
    required this.accessExpires,
    required this.refreshToken,
    required this.refreshExpires,
  });

  factory Data.fromMap(Map<String, dynamic> json) => Data(
        customer: Customer.fromMap(json["customer"]),
        token: json["token"] ?? '',
        accessExpires: json["access_expires"] ?? '',
        refreshToken: json["refresh_token"] ?? '',
        refreshExpires: json["refresh_expires"] ?? '',
      );

  Map<String, dynamic> toMap() => {
        "customer": customer.toMap(),
        "token": token,
        "access_expires": accessExpires,
        "refresh_token": refreshToken,
        "refresh_expires": refreshExpires,
      };
}

class Customer {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String city;
  final int isVerified;
  final int isActive;
  final String image;
  final dynamic addresses;

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.city,
    required this.isVerified,
    required this.isActive,
    required this.image,
    this.addresses,
  });

  factory Customer.fromMap(Map<String, dynamic> json) => Customer(
        id: json["id"] ?? 0,
        firstName: json["first_name"] ?? '',
        lastName: json["last_name"] ?? '',
        phone: json["phone"] ?? '',
        email: json["email"] ?? '',
        city: json["city"] ?? '',
        isVerified: json["is_verified"] ?? 0,
        isActive: json["is_active"] ?? 0,
        image: json['image'] != null ? "$ImageUrl${json['image']}" : '',
        addresses: json['addresses'], // يمكن لاحقًا نعمل نموذج له إذا كان List
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "phone": phone,
        "email": email,
        "city": city,
        "is_verified": isVerified,
        "is_active": isActive,
        "image": image,
        "addresses": addresses,
      };
}
