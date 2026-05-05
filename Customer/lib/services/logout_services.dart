import 'package:biadgo/constants/apiUrl.dart';
import 'package:biadgo/models/logout_model.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class LogoutServices {
  Future<LogoutModel?> logout({
    required String token,
  }) async {
    try {
      final GetStorage getStorage = GetStorage();
      final token = getStorage.read('token') as String?;
      final Uri url = Uri.parse('$apiUrl/logout');
      final response = await http.post(
        url,
        body: {
          'token': token,
        },
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        debugPrint(responseBody);
        final logoutModel = LogoutModel.fromJson(responseBody);
        return logoutModel;
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
