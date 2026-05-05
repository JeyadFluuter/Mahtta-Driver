import 'dart:convert';
import 'package:biadgo/constants/apiUrl.dart';
import 'package:biadgo/models/forgot_password_model.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordServices {
  Future<Map<String, dynamic>> changePhone({
    required String phone,
  }) async {
    try {
      final GetStorage getStorage = GetStorage();
      final token = getStorage.read('token') as String?;
      final Uri url = Uri.parse('$apiUrl/send-reset-otp');
      final response = await http.post(
        url,
        body: json.encode({
          'phone': phone,
        }),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        debugPrint(responseBody);
        final forgotPasswordModel = ForgotPasswordModel.fromJson(responseBody);
        return {'success': true, 'data': forgotPasswordModel};
      } else {
        debugPrint('خطاء في الاستجابة: ${response.statusCode}');
        debugPrint('نص الاستجابة: ${response.body}');
        
        String errorMessage = "حدث خطأ غير متوقع";
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // Fallback to generic message
        }
        
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      debugPrint('خطأ أثناء الإتصال بالسيرفر: $e');
      return {'success': false, 'message': 'لا يوجد اتصال بالإنترنت'};
    }
  }
}
