// lib/services/driver_location_services.dart
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/model/driver_location_model.dart';


class DriverLocationServices {
  Future<DriverLocationModel?> driverLocation({
    required double currentLat,
    required double currentLng,
    int? orderId,
  }) async {
    try {
      final token = GetStorage().read<String>('token') ?? '';
      final Uri url = Uri.parse('$apiUrl/orders/update-location');

      final response = await http.put(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_lat': currentLat,
          'current_lng': currentLng,
          'order_id': orderId,
        }),
        
      );
            print('🚀 Driver Location Request: $response');


      if (response.statusCode == 200) {
        final loc = DriverLocationModel.fromJson(response.body);
        return loc;
      } else {
        return null;
      }
    } catch (e) {
            print('🚀 error  Location Request: $e');

      return null;
    }
  }
}
