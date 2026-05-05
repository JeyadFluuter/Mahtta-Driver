import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/model/shipment_type_model.dart';

class MyShipmenyTypeServices {
  Future<List<ShipmentTypeModel>> myShipmentTypesData() async {
    final token = GetStorage().read('token');

    final response = await http.get(
      Uri.parse('$apiUrl/shipment-types/my-shipment-types'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    final responseBody = response.body;
    debugPrint("responseBody = $responseBody");
    return ShipmentTypeModelResponse.fromJson(responseBody).data;
  }
}
