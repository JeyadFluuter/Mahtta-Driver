import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/model/statistics_model.dart';

class StatisticsServices {
  final _box = GetStorage();
  Future<StatisticsModel?> fetchStats({String period = '7d'}) async {
    final token = _box.read('token');

    try {
      final uri = Uri.parse('$apiUrl/stats?period=$period');

      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final jsonBody = jsonDecode(res.body);
        return StatisticsModel.fromMap(jsonBody['data']);
      } else {
        debugPrint('⛔️ Stats API error ${res.statusCode}: ${res.body}');
        return null;
      }
    } catch (e) {
      debugPrint('⛔️ Stats API exception: $e');
      return null;
    }
  }
}
