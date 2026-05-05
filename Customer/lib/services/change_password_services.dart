import 'package:biadgo/constants/apiUrl.dart';
import 'package:biadgo/models/change_password_model.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ChangePasswordServices {
  Future<ChangePasswordModel?> changePassword(
      {required String oldPassword,
      required String password,
      required String passwordConfirmation}) async {
    try {
      final GetStorage getStorage = GetStorage();
      final token = getStorage.read('token') as String?;
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
