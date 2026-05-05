import 'package:biadgo/constants/apiUrl.dart';
import 'package:biadgo/models/change_phone_model.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ChangePhoneServices {
  Future<ChangePhoneModel?> changePhone({
    required String phone,
  }) async {
    try {
      final GetStorage getStorage = GetStorage();
      final token = getStorage.read('token') as String?;
      final Uri url = Uri.parse('$apiUrl/update-phone-number');
      final response = await http.put(
        url,
        body: {
          'phone': phone,
        },
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        debugPrint(responseBody);
        final changePhondModel = ChangePhoneModel.fromJson(responseBody);
        return changePhondModel;
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
