// ignore: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:piaggio_driver/model/set_Location_model.dart';
import 'package:piaggio_driver/services/set_Location_services.dart';

class SetLocationController extends GetxController {
  final SetLocationServices setLocationServices = SetLocationServices();
  final GetStorage getStorage = GetStorage();
  var setLocationModel = Rxn<SetLocationModel>();
  final _svc = SetLocationServices();

  Future<bool> sendLocation({
    required double currentLat,
    required double currentLng,
    required double workingRadius,
  }) async {
    final result = await _svc.setLocation(
      currentLat: currentLat,
      currentLng: currentLng,
      workingRadius: workingRadius,
    );

    if (result != null) {
      setLocationModel.value = result;

      final box = GetStorage();
      box.write('working_lat', currentLat.toDouble());
      box.write('working_lng', currentLng.toDouble());
      box.write('working_radius', workingRadius.toDouble());

      debugPrint(
          "✅ saved lat=${box.read('working_lat')}, lng=${box.read('working_lng')}, rad=${box.read('working_radius')}");

      Get.snackbar('تحديد الموقع', 'تم الإرسال بنجاح');
      return true;
    } else {
      Get.snackbar('خطأ', 'تعذّر إرسال الموقع');
      return false;
    }
  }
}
