import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/model/change_password_welcome_model.dart';

class ChangePasswordWelcomeServices {
  Future<ChangePasswordWelcomeModel?> resetPassword(
      {required String phone,
      required String password,
      required String confirmPassword}) async {
    try {
      final token = GetStorage().read('token');
      final Uri url = Uri.parse('$apiUrl/reset_password');
      final response = await http.put(
        url,
        body: {
          'phone': phone,
          'password': password,
          'confirmPassword': confirmPassword,
        },
        headers: {
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
