// add_shipment_type_services.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';

class AddShipmentTypeServices {
  Future<bool> updateShipmentTypes(List<int> ids) async {
    final token = GetStorage().read('token');

    try {
      final res = await http.put(
        Uri.parse('$apiUrl/shipment-types/update-shipment-types'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({'shipment_type_ids': ids}),
      );

      if (res.statusCode == 200) {
        return true;
      } else {
        debugPrint('Error ${res.statusCode} → ${res.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Server error: $e');
      return false;
    }
  }
}
