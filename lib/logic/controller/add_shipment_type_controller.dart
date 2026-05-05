import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/routes/routes.dart';
import 'package:piaggio_driver/services/add_shipment_type_services.dart';

class AddShipmentTypeController extends GetxController {
  final _service = AddShipmentTypeServices();

  Future<void> send(List<int> ids) async {
    if (ids.isEmpty) {
      Get.snackbar('تنبيه', 'اختر نوعًا واحدًا على الأقل');
      return;
    }

    final ok = await _service.updateShipmentTypes(ids);
    if (ok) {
      Get.snackbar('نجاح', 'تمّ تحديث أنواع البضاعة',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3));
      Get.offAllNamed(AppRoutes.homescreen);
    } else {
      Get.snackbar('خطأ', 'تعذّر تحديث أنواع البضاعة',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4));
    }
  }
}
