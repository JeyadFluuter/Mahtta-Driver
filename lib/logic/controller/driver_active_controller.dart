import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:piaggio_driver/constants/api_Url.dart';

class DriverActiveController extends GetxController {
  Future<bool> updateActiveStatus({required bool isOnline}) async {
    try {
      final data = {'is_active': isOnline ? 1 : 0};
      final token = GetStorage().read('token');

      final response = await http
          .put(
            Uri.parse('$apiUrl/update-active-status'),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        Get.snackbar(
          "نجاح",
          isOnline ? "أصبحت متصلاً" : "تم إيقاف الاتصال",
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check, color: Colors.white),
        );
        return true;
      } else {
        Get.snackbar(
          "فشل",
          "تعذّر تحديث الحالة",
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.error, color: Colors.white),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "خطأ في الاتصال",
        "حدث خطأ أثناء محاولة تغيير الحالة",
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      );
      return false;
    }
  }
}
