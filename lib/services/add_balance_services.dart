import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/model/add_balance_model.dart';

class AddBalanceServices {
  Future<dynamic> addBalance({
    required String code,
  }) async {
    try {
      final Uri url = Uri.parse('$apiUrl/wallet/redeem');
      final token = GetStorage().read('token');

      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(
          {
            'code': code,
          },
        ),
      );

      final body = jsonDecode(res.body);
      
      // Handle Validation Errors (422) or Logic Errors (200 with error == 1 or status == false)
      if (res.statusCode == 422 || body['error'] == 1 || body['status'] == false) {
        debugPrint('❌ API Error (${res.statusCode}) → ${res.body}');
        throw res.body; // Throw the raw body to let controller parse the 'message'
      }

      if (res.statusCode == 200) {
        return {
          'model': AddBalanceModel.fromMap(body),
          'message': body['message'] ?? "تم إضافة الرصيد بنجاح",
        };
      } else {
        debugPrint('❌ Unknown Error ${res.statusCode} → ${res.body}');
        throw res.body;
      }
    } catch (e) {
      debugPrint('❌ Server error: $e');
      rethrow;
    }
  }
}
