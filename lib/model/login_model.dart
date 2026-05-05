import 'dart:convert';
import 'package:piaggio_driver/constants/api_Url.dart';

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
        data: json["data"] != null
            ? Data.fromMap(json["data"])
            : Data.empty(), // ✅ تجنب Null
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

  Data({
    required this.customer,
    required this.token,
  });

  factory Data.fromMap(Map<String, dynamic> json) => Data(
        customer: json["driver"] != null
            ? Customer.fromMap(json["driver"])
            : Customer.empty(),
        token: json["token"] ?? '',
      );

  Map<String, dynamic> toMap() => {
        "customer": customer.toMap(),
        "token": token,
      };

  factory Data.empty() => Data(
        customer: Customer.empty(),
        token: '',
      );
}

class Customer {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String driverImage;
  final String licenseNumber;
  final String licenseType;
  final String licenseExpiry;
  final String passportNumber;
  final String passportExpiry;
  final int isActive;
  final int isVerified;
  final String status;
  final String currentLat;
  final String currentLng;

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.driverImage,
    required this.licenseNumber,
    required this.licenseType,
    required this.licenseExpiry,
    required this.passportNumber,
    required this.passportExpiry,
    required this.isActive,
    required this.isVerified,
    required this.status,
    required this.currentLat,
    required this.currentLng,
  });

  factory Customer.fromMap(Map<String, dynamic> json) => Customer(
        id: json["id"] ?? 0,
        firstName: json["first_name"] ?? '',
        lastName: json["last_name"] ?? '',
        phone: json["phone"] ?? '',
        email: json["email"] ?? '',
        driverImage: json['driver_image'] != null
            ? "$imageUrl${json['driver_image']}"
            : '',
        licenseNumber: json["license_number"] ?? '',
        licenseType: json["license_type"] ?? '',
        licenseExpiry: json["license_expiry"] ?? '',
        passportNumber: json["passport_number"] ?? '',
        passportExpiry: json["passport_expiry"] ?? '',
        isActive: json["is_active"] ?? 0,
        isVerified: json["is_verified"] ?? 0,
        status: json["status"] ?? '',
        currentLat: json["current_lat"] ?? '',
        currentLng: json["current_lng"] ?? '',
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "phone": phone,
        "email": email,
        "driver_image": driverImage,
        "license_number": licenseNumber,
        "license_type": licenseType,
        "license_expiry": licenseExpiry,
        "passport_number": passportNumber,
        "passport_expiry": passportExpiry,
        "is_active": isActive,
        "is_verified": isVerified,
        "status": status,
        "current_lat": currentLat,
        "current_lng": currentLng,
      };

  /// دالة لإنشاء كائن فارغ
  factory Customer.empty() => Customer(
        id: 0,
        firstName: '',
        lastName: '',
        phone: '',
        email: '',
        driverImage: '',
        licenseNumber: '',
        licenseType: '',
        licenseExpiry: '',
        passportNumber: '',
        passportExpiry: '',
        isActive: 0,
        isVerified: 0,
        status: '',
        currentLat: '',
        currentLng: '',
      );
}
