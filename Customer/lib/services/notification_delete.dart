import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../constants/apiUrl.dart';

class NotificationDelete {
  static Future<void> notificationDelete({required String fcmToken}) async {
    final box = GetStorage();
    final token = box.read('token');

    final url = Uri.parse(
      '$baseUrl/api/device-token',
    );

    final res = await http.delete(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
        if (token != null && token.toString().isNotEmpty)
          'Authorization': 'Bearer $token',
      },
      body: {
        'fcm_token': fcmToken,
      },
    );
    debugPrint("🗑️ Delete Token Response: ${res.body}");
  }
}
