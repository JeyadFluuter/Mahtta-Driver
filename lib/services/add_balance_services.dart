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

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        // Check for logic error as per backend spec
        if (body['error'] == 1) {
          debugPrint('❌ Logic Error (200) → ${res.body}');
          throw res.body;
        }
        return {
          'model': AddBalanceModel.fromMap(body),
          'message': body['message'] ?? "تم إضافة الرصيد بنجاح",
        };
      } else {
        debugPrint('❌  Error ${res.statusCode} → ${res.body}');
        throw res.body;
      }
    } catch (e) {
      debugPrint('❌  Server error: $e');
      rethrow;
    }
  }
}
