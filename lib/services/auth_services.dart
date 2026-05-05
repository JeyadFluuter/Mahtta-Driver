// auth_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/model/login_model.dart';

class AuthService {
  Future<LoginResponse?> register({
    required String firstName,
    required String lastName,
    required String licenseNumber,
    required String phone,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String licenseType,
    required String licenseExpiry,
    required String passportNumber,
    required String passportExpiry,
    required String driverImageName,
    required String driverImageData,
    required String passportImageName,
    required String passportImageData,
    required String licenseFrontImageName,
    required String licenseFrontImageData,
    required String licenseBackImageName,
    required String licenseBackImageData,
    required List<int> preferredShipmentTypeIds,
    String? inviterPhone,
  }) async {
    try {
      final Uri url = Uri.parse('$apiUrl/register');
      final body = {
        'first_name': firstName,
        'last_name': lastName,
        'license_number': licenseNumber,
        'phone': phone,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'license_type': licenseType,
        'license_expiry': licenseExpiry,
        'passport_number': passportNumber,
        'passport_expiry': passportExpiry,
        //Driver
        'driver_image_name': driverImageName,
        'driver_image_data': driverImageData,
        'passport_image_name': passportImageName,
        'passport_image_data': passportImageData,
        'license_front_image_name': licenseFrontImageName,
        'license_front_image_data': licenseFrontImageData,
        'license_back_image_name': licenseBackImageName,
        'license_back_image_data': licenseBackImageData,
        'preferred_shipment_type_ids': preferredShipmentTypeIds,
        if (inviterPhone != null && inviterPhone.isNotEmpty)
          'inviter_phone': inviterPhone,
      };
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 60));
      if (res.statusCode == 200) {
        return LoginResponse.fromMap(jsonDecode(res.body));
      } else {
        throw res;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<LoginResponse?> login({
    required String phone,
    required String password,
  }) async {
    try {
      final Uri url = Uri.parse('$apiUrl/login');

      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phone, 'password': password}),
      ).timeout(const Duration(seconds: 40));

      debugPrint('🔐 Login status: ${res.statusCode}');

      if (res.statusCode == 200) {
        return LoginResponse.fromMap(jsonDecode(res.body));
      } else {
        debugPrint('❌ Error ${res.statusCode} → ${res.body}');
        try {
          final data = jsonDecode(res.body);
          // اكتشاف حالة الحساب غير المفعل - الباك يرجع errors.otp أو رسالة تحتوي على "غير مُفعَّل"
          final errors = data['errors'];
          final msg = data['message']?.toString() ?? '';
          if ((errors is Map && errors.containsKey('otp')) ||
              msg.contains('غير مُفع') ||
              msg.contains('unverified') ||
              msg.contains('تفعيل')) {
            throw 'UNVERIFIED_ACCOUNT';
          }
          throw msg.isNotEmpty ? msg : "الرقم أو كلمة المرور غير صحيحة";
        } catch (ex) {
          if (ex is String) rethrow;
          throw "الرقم أو كلمة المرور غير صحيحة، أو الحساب ليس لسائق";
        }
      }
    } catch (e) {
      debugPrint('❌ Server error: $e');
      rethrow;
    }
  }

  Future<bool> sendOtp({required String phone}) async {
    try {
      final Uri url = Uri.parse('$apiUrl/send-reset-otp');
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phone}),
      ).timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        return true;
      } else {
        debugPrint('❌  Error ${res.statusCode} → ${res.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌  Server error: $e');
      return false;
    }
  }
}
