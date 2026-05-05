import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/model/total_profit_model.dart';

class ProfitSummaryService {
  final _box = GetStorage();

  Future<ProfitSummary?> fetchSummary() async {
    final token = _box.read('token');

    try {
      final res = await http.get(
        Uri.parse('$apiUrl/summary'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final jsonBody = jsonDecode(res.body);
        return ProfitSummary.fromMap(jsonBody['data']);
      } else {
        debugPrint('⛔️ Summary API error ${res.statusCode}: ${res.body}');
        return null;
      }
    } catch (e) {
      debugPrint('⛔️ Summary API exception: $e');
      return null;
    }
  }
}
