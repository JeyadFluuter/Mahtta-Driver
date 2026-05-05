import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/model/change_password_screen_model.dart';

class ChangePasswordServices {
  Future<ChangePasswordModel?> changePassword(
      {required String oldPassword,
      required String password,
      required String passwordConfirmation}) async {
    try {
      final token = GetStorage().read('token');
      final Uri url = Uri.parse('$apiUrl/update-password');
      final response = await http.put(
        url,
        body: {
          'old_password': oldPassword,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        final changePasswordModel = ChangePasswordModel.fromJson(responseBody);
        return changePasswordModel;
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
