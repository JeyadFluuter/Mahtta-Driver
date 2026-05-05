import 'package:biadgo/constants/apiUrl.dart';
import 'package:biadgo/models/shipment_types_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShipmentTypesServices {
  Future<List<dataShipmentTypes>> shipmentTypesData() async {
    final response = await http.get(
      Uri.parse('$apiUrl/shipment-types'),
      headers: {
        "Content-Type": "application/json",
      },
    );
    final responseBody = response.body;
    debugPrint("responseBody = $responseBody");
    return dataShipmentTypesFromJson(responseBody);
  }
}
