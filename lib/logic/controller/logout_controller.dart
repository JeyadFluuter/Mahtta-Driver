import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/views/Auth/welcome_screen.dart';
import 'package:piaggio_driver/services/order_request_services.dart';
import 'package:piaggio_driver/logic/controller/location_controller.dart';

class LogOutController extends GetxController {
  final RxBool isLoading = false.obs;

  Future<void> logout() async {
    if (isLoading.value) return;
    isLoading.value = true;

    final box = GetStorage();
    final tokenValue = box.read('token') ?? '';
    // final pusher =
    //     Get.isRegistered<PusherService>() ? Get.find<PusherService>() : null;
    final loc = Get.isRegistered<LocationController>()
        ? Get.find<LocationController>()
        : null;

    try {
      try {
       // await pusher?.disconnect();
      } catch (_) {}
      try {
        loc?.stopLocationTimer();
      } catch (_) {}

      http.Response? response;
      if (tokenValue.toString().isNotEmpty) {
        response = await http.post(
          Uri.parse('$apiUrl/logout'),
          headers: {
            "Authorization": "Bearer $tokenValue",
            "Accept": "application/json",
          },
        );
      }
      try {
      
      } catch (_) {}
      try {
      } catch (_) {}

      await box.erase();
      final okStatus = response == null ||
          response.statusCode == 200 ||
          response.statusCode == 401 ||
          response.statusCode == 419;
          
      Get.offAll(() => const WelcomeScreen());

      if (okStatus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.snackbar("تسجيل الخروج", "تم تسجيل الخروج بنجاح",
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              icon: const Icon(Icons.check, color: Colors.white),
              colorText: Colors.white);
        });
      } else {
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.snackbar("تنبيه",
              "تم مسح الجلسة محليًا لكن السيرفر رجّع ${response!.statusCode}",
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
              icon: const Icon(Icons.warning, color: Colors.white),
              colorText: Colors.white);
        });
      }
    } catch (e) {
      Get.snackbar("خطأ", "حدث خطأ أثناء تسجيل الخروج: $e",
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.error, color: Colors.white),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> deleteAccount(String password) async {
    if (isLoading.value) return null;
    isLoading.value = true;

    final box = GetStorage();
    final tokenValue = box.read('token') ?? '';
    final pusher =
        Get.isRegistered<PusherService>() ? Get.find<PusherService>() : null;
    final loc = Get.isRegistered<LocationController>()
        ? Get.find<LocationController>()
        : null;

    try {
      try {
        await pusher?.disconnect();
      } catch (_) {}
      try {
        loc?.stopLocationTimer();
      } catch (_) {}

      if (tokenValue.toString().isNotEmpty) {
        final response = await http.delete(
          Uri.parse('$apiUrl/delete-account'),
          headers: {
            "Authorization": "Bearer $tokenValue",
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
          body: jsonEncode({"password": password}),
        );

        if (response.statusCode == 200) {
          try {
      
          } catch (_) {}

          await box.erase();
          Get.offAll(() => const WelcomeScreen());
          return null;
        } else {
          final data = jsonDecode(response.body);
          return data['message'] ?? "كلمة المرور غير صحيحة";
        }
      }
      return "لم يتم العثور على جلسة صالحة";
    } catch (e) {
      return "حدث خطأ أثناء حذف الحساب: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
