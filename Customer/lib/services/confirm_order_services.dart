import 'dart:convert';
import 'package:biadgo/constants/apiUrl.dart';
import 'package:biadgo/models/confirm_order_model.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ConfirmOrderServices {
  Future<DataConfirmOrder?> confirmOrder({
    required String? sourceAddress,
    required String? sourceLat,
    required String? sourceLng,
    required String? destinationAddress,
    required String? destinationLat,
    required String? destinationLng,
    required int shipmentTypeId,
    required String? paymentMethod,
    required int vehicleTypeId,
    required int autoDispose,
  }) async {
    try {
      final GetStorage getStorage = GetStorage();
      final token = getStorage.read('token') as String?;
      final Uri url = Uri.parse('$apiUrl/orders/confirm');
      final response = await http.post(
        url,
        body: {
          'source_address': sourceAddress,
          'source_lat': sourceLat,
          'source_lng': sourceLng,
          'destination_address': destinationAddress,
          'destination_lat': destinationLat,
          'destination_lng': destinationLng,
          'shipment_type_id': shipmentTypeId.toString(),
          'vehicle_type_id': vehicleTypeId.toString(),
          'payment_method': paymentMethod,
          'auto_dispose': autoDispose.toString(),
        },
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedBody = json.decode(response.body);
        debugPrint("Decoded JSON: $decodedBody");
        final dataConfirmOrder =
            DataConfirmOrder.fromJson(decodedBody as Map<String, dynamic>);
        return dataConfirmOrder;
      } else {
        final errorMsg = json.decode(response.body)['message'] ?? 'فشل في إنشاء الطلب';
        throw Exception(errorMsg);
      }
    } catch (e) {
      rethrow;
    }
  }
}
