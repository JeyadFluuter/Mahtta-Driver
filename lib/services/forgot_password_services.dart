import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';

class ForgotPasswordServices {
  Future<String?> changePhone({
    required String phone,
  }) async {
    try {
      final token = GetStorage().read('token');
      final Uri url = Uri.parse('$apiUrl/send-reset-otp');
      final response = await http.post(
        url,
        body: {
          'phone': phone,
        },
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return null; // Success
      } else {
        debugPrint('خطاء في الاستجابة: ${response.statusCode}');
        debugPrint('نص الاستجابة: ${response.body}');
        try {
          final responseBody = json.decode(response.body);
          final msg = responseBody['message'] ?? 'الرقم غير مسجل كـ سائق لدينا';
          return msg;
        } catch (_) {
          return 'الرقم غير مسجل كـ سائق لدينا أو حدث خطأ في الخادم';
        }
      }
    } catch (e) {
      debugPrint('خطأ أثناء الإتصال بالسيرفر: $e');
      return 'خطأ أثناء الإتصال بالسيرفر';
    }
  }
}
