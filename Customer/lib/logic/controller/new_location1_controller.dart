import 'dart:convert';
import 'package:biadgo/widgets/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../constants/apiUrl.dart';
import 'package:http/http.dart' as http;

class NewLocation1Controller extends GetxController {
  final GetStorage getStorage = GetStorage();
  final TextEditingController nameSourceController = TextEditingController();
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController pickupLatController = TextEditingController();
  final TextEditingController pickupLngController = TextEditingController();
  final TextEditingController nameDestinationController =
      TextEditingController();
  final TextEditingController dropoffController = TextEditingController();
  final TextEditingController dropoffLatController = TextEditingController();
  final TextEditingController dropoffLngController = TextEditingController();
  final TextEditingController pickupLocationController =
      TextEditingController();
  final TextEditingController dropoffLocationController =
      TextEditingController();
  String? pickupLat;
  String? pickupLng;
  String? dropoffLng;
  String? dropoffLat;

  void clearFields() {
    pickupLocationController.clear();
    dropoffLocationController.clear();
    pickupLatController.clear();
    pickupLngController.clear();
    dropoffLngController.clear();
    dropoffLatController.clear();
  }

  Future<void> addnewlocation() async {
    final String? token = getStorage.read('token') as String?;
    try {
      final data = {
        'source_address': nameSourceController.text.trim(),
        'source_lat': pickupLatController.text.trim(),
        'source_lng': pickupLngController.text.trim(),
        'destination_address': nameDestinationController.text.trim(),
        'destination_lat': dropoffLatController.text.trim(),
        'destination_lng': dropoffLngController.text.trim(),
      };

      final response = await http.post(
        Uri.parse('$apiUrl/addresses'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          "نجاح",
          "تمت إضافة الموقع بنجاح",
          icon: const Icon(Icons.check),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        );
        debugPrint("Response: ${response.body}");
        Get.to(() => NavBar());
      } else {
        Get.snackbar(
          "خطأ",
          "فشلت عملية الإضافة: ${response.body}",
          icon: const Icon(Icons.error),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "حدث خطأ غير متوقع: $e",
      );
    }
  }
}
