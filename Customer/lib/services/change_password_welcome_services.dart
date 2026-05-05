import 'package:biadgo/constants/apiUrl.dart';
import 'package:biadgo/models/change_password_welcome_model.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ChangePasswordWelcomeServices {
  Future<ChangePasswordWelcomeModel?> resetPassword({
    required String phone,
    required String password,
    required String confirmPassword,
    required String otpCode,
  }) async {
    try {
      final GetStorage getStorage = GetStorage();
      final token = getStorage.read('token') as String?;
      final Uri url = Uri.parse('$apiUrl/reset_password');
      final response = await http.put(
        url,
        body: {
          'phone': phone,
          'password': password,
          'password_confirmation': confirmPassword,
          'otp_code': otpCode,
        },
        headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        final changePasswordWelcomeModel =
            ChangePasswordWelcomeModel.fromJson(responseBody);
        return changePasswordWelcomeModel;
      } else {
        debugPrint('خطاء في الاستجابة: ${response.statusCode}');
        debugPrint('نص الاستجابة: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('خطأ أثناء الإتصال بالسيرفر: $e');
      return null;
    }
  }
}
