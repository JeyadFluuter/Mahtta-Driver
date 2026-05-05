import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../constants/apiUrl.dart';

class Notificationn {
  static Future<void> notification({
    required String fcmToken,
    required String platform,
    String? deviceId,
  }) async {
    final box = GetStorage();
    final token = box.read('token');

    final url = Uri.parse(
      '$baseUrl/api/device-token',
    );

    final body = <String, String>{
      'fcm_token': fcmToken,
      'platform': platform,
      if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
    };

    final res = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
        if (token != null && token.toString().isNotEmpty)
          'Authorization': 'Bearer $token',
      },
      body: body,
    );

    debugPrint(res.body.toString());
  }
}
