import 'dart:convert';
import 'package:biadgo/constants/apiUrl.dart';
import 'package:biadgo/models/order_estimate_model.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class EstimateOrderServices {
  Future<DataEsimate?> estimateOrder({
    required String? sourceAddress,
    required String? sourceLat,
    required String? sourceLng,
    required String? cargoDescription,
    required String? destinationAddress,
    required String? destinationLat,
    required String? destinationLng,
    required int shipmentTypeId,
    required int vehicleTypeId,
    required int cargoWeight,
  }) async {
    try {
      final GetStorage getStorage = GetStorage();
      final token = getStorage.read('token') as String?;
      final Uri url = Uri.parse('$apiUrl/orders/estimate');

      final response = await http.post(
        url,
        body: {
          'source_address': sourceAddress,
          'source_lat': sourceLat,
          'source_lng': sourceLng,
          'cargo_description': cargoDescription,
          'destination_address': destinationAddress,
          'destination_lat': destinationLat,
          'destination_lng': destinationLng,
          'shipment_type_id': shipmentTypeId.toString(),
          'vehicle_type_id': vehicleTypeId.toString(),
          'cargo_weight': cargoWeight.toString(),
        },
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        debugPrint("Decoded JSON: $decodedBody");

        final dataEsimate =
            DataEsimate.fromJson(decodedBody as Map<String, dynamic>);

        return dataEsimate;
      } else {
        debugPrint('خطاء في الاستجابة: ${response.statusCode}');
        debugPrint('نص الاستجابة: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('خطأ أثناء الإتصال بالسيرفر: $e');
      return null;
    }
  }
}
