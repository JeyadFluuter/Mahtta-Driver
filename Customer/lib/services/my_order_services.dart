import 'package:biadgo/constants/apiUrl.dart';
import 'package:biadgo/models/my_order_model.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class MyOrderDataServices {
  Future<List<MyOrder>> myOrderData({int page = 1, int perPage = 15}) async {
    final GetStorage getStorage = GetStorage();
    final token = getStorage.read('token') as String?;
    if (token == null) {
      debugPrint('❌  لا يوجد توكن محفوظ');
      return [];
    }
    final uri =
        Uri.parse('$apiUrl/orders/my-orders?page=$page&perPage=$perPage');

    final res = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode == 200) {
      final orders = myordersFromJson(res.body);
      return orders;
    } else if (res.statusCode == 401) {
      throw Exception('401');
    } else {
      debugPrint('❌  ERROR ${res.statusCode}: ${res.body}');
      return [];
    }
  }
}
