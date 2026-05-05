// ignore: file_names
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/model/set_Location_model.dart';

class SetLocationServices {
  Future<SetLocationModel?> setLocation({
    required double currentLat,
    required double currentLng,
    required double workingRadius,
  }) async {
    try {
      final token = GetStorage().read<String>('token') ?? '';
      final url = Uri.parse('$apiUrl/orders/set-location');
      final res = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'current_lat': currentLat,
          'current_lng': currentLng,
          'working_radius': workingRadius,
        }),
      );

      if (res.statusCode == 200) {
        return SetLocationModel.fromJson(res.body);
      }
      debugPrint('❌‏ ${res.statusCode} → ${res.body}');
      return null;
    } catch (e) {
      debugPrint('❌‏ $e');
      return null;
    }
  }
}
