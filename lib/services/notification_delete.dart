import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:piaggio_driver/constants/api_Url.dart';

class NotificationDelete {
  static Future<void> notificationDelete() async {
    final box = GetStorage();
    final token = box.read('token');

    final url = Uri.parse(
      '$baseUrl/api/device-tokens',
    );

    final res = await http.delete(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
        if (token != null && token.toString().isNotEmpty)
          'Authorization': 'Bearer $token',
      },
    );
    debugPrint(res.body.toString());
  }
}
