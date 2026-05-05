import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/model/my_order_model.dart';

class MyOrderDataServices {
  final GetStorage _box = GetStorage();
  Future<(List<MyOrder>, int)> fetchPage({
    required int page,
    int perPage = 15,
  }) async {
    final token = _box.read('token');
    if (token == null) throw Exception('Token not found');

    final uri =
        Uri.parse('$apiUrl/orders/my-orders?page=$page&perPage=$perPage');

    final res = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    debugPrint('➡️  GET $uri  👉  ${res.statusCode}');
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }
    final Map<String, dynamic> j = jsonDecode(res.body);
    debugPrint('Response JSON: $j');
    final raw = j['data']?['pagination']?['total_pages'];
    final totalPages =
        raw is int ? raw : int.tryParse(raw?.toString() ?? '') ?? 1;
    debugPrint('Total pages: $totalPages');
    final items = myordersFromJson(res.body);
    debugPrint('Items: $items');

    return (items, totalPages);
  }
}
