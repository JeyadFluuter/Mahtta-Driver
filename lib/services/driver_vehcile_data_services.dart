// auth_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/model/driver_vehicle_data_model.dart';

class DriverVehcileDataServices {
  Future<DriverVehicleDataModel?> driverVehcileData({
    required String vehicle_type,
    required String plate_number,
    required String chassis_number,
    required String vehicle_brand,
    required String vehicle_color,
    required String vehicle_brochure,
    required String model,
    required String capacity,
    required String insurance_document,
    required String vehicle_front_image,
    required String vehicle_back_image,
    required String vehicle_right_image,
    required String vehicle_left_image,
    required String vehicle_inside_image,
    required String vehicle_trunk_image,
  }) async {
    try {
      final Uri url = Uri.parse('$apiUrl/driver-vehicle-data');
      debugPrint('🚀 Sending vehicle data to: $url');
      final token = GetStorage().read('token');

      final body = {
        'vehicle_type_id': vehicle_type,
        'plate_number': plate_number,
        'chassis_number': chassis_number,
        'vehicle_brand': vehicle_brand,
        'vehicle_color': vehicle_color,
        'vehicle_brochure': vehicle_brochure,
        'model': model,
        'capacity': capacity,
        'insurance_document': insurance_document,
        'vehicle_front_image': vehicle_front_image,
        'vehicle_back_image': vehicle_back_image,
        'vehicle_right_side_image': vehicle_right_image,
        'vehicle_left_side_image': vehicle_left_image,
        'vehicle_inside_image': vehicle_inside_image,
        'vehicle_trunk_image': vehicle_trunk_image,
      };

      final res = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        Get.snackbar('تم', 'تمّ إضافة بيانات المركبة بنجاح');
        final decoded = jsonDecode(res.body);
        final vehicleMap = decoded['data']?['vehicles'];

        if (vehicleMap == null) return null;

        return DriverVehicleDataModel.fromMap(vehicleMap);
      } else {
        debugPrint('❌  Error ${res.statusCode} → ${res.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌  Server error: $e');
      return null;
    }
  }
}
