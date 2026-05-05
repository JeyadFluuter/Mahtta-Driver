import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:biadgo/constants/apiUrl.dart';
import 'package:biadgo/routes/routes.dart';
import 'package:biadgo/services/order_accepted_services.dart';

class LogOutController extends GetxController {
  final _box = GetStorage();
  final GetStorage getStorage = GetStorage();
  final RxBool busy = false.obs;

  Future<void> logout() async {
    if (busy.value) return;
    busy.value = true;

    try {
      if (Get.isDialogOpen == true) Get.back();
      if (Get.isBottomSheetOpen == true) Get.back();

      final String? token = getStorage.read('token') as String?;

      http.Response? res;
      if (token != null && token.isNotEmpty) {
        try {
          res = await http.post(
            Uri.parse('$apiUrl/logout'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          ).timeout(const Duration(seconds: 6));
        } catch (_) {}
      }
      await _localSignOut();
      final ok = res == null ||
          res.statusCode == 200 ||
          res.statusCode == 401 ||
          res.statusCode == 419;
          
      if (Get.context != null) {
        Get.snackbar(
          'تسجيل الخروج',
          ok ? 'تم تسجيل الخروج بنجاح' : 'تم مسح الجلسة محليًا (HTTP ${res.statusCode})',
          backgroundColor: ok ? Colors.green : Colors.orange,
          colorText: Colors.white,
          icon: Icon(ok ? Icons.check : Icons.warning, color: Colors.white),
          duration: const Duration(seconds: 2),
        );
      }

      Get.offAllNamed(AppRoutes.welcomeScreen);
    } finally {
      busy.value = false;
    }
  }

  Future<void> _localSignOut() async {
    try {
      await OrderAcceptedServices().dispose();
    } catch (_) {}

    try {} catch (_) {}
    await _box.erase();
  }
}
