import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/model/logs_profit_models.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class LogsProfitServices {
  final _box = GetStorage();

  Future<LogsProfitModels?> fetchWallet() async {
    final token = _box.read('token');
    try {
      final res = await http.get(
        Uri.parse('$apiUrl/logs'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        return LogsProfitModels.fromJson(res.body);
      } else {
        debugPrint('⛔️ Logs API error ${res.statusCode}: ${res.body}');
        return null;
      }
    } catch (e) {
      debugPrint('⛔️ Logs API exception: $e');
      return null;
    }
  }
}
