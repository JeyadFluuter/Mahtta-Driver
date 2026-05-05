import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/model/rejection_orders_model.dart';

class RejectionOrderServices {
  final _box = GetStorage();

  Future<RejectionOrdersModel?> rejectOrder({required int orderId}) async {
    final token = _box.read('token');

    try {
      final uri = Uri.parse('$apiUrl/orders/reject-order');
      final res = await http.post(
        uri,
        body: jsonEncode({'order_id': orderId}),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('↩️ reject-order ${res.statusCode}: ${res.body}');
      if (res.statusCode == 200 || res.statusCode == 201) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) {
          final data = decoded['data'] ?? decoded;
          return RejectionOrdersModel.fromAny(data);
        }
        if (decoded is List) {
          return RejectionOrdersModel.fromAny(decoded);
        }
        return RejectionOrdersModel.fromAny(decoded);
      } else {
        debugPrint('⛔️ reject-order error ${res.statusCode}: ${res.body}');
        return null;
      }
    } catch (e) {
      debugPrint('⛔️ reject-order exception: $e');
      return null;
    }
  }
}
