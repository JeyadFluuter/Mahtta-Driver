import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:biadgo/constants/apiUrl.dart';

class DeleteMyLocationController extends GetxController {
  final isDeleting = <int, bool>{}.obs;
  final GetStorage getStorage = GetStorage();
  Future<void> deleteLocation(int locationId) async {
    final String? token = getStorage.read('token') as String?;

    isDeleting[locationId] = true;
    update();

    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/addresses/$locationId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        isDeleting.remove(locationId);
        update();

        Get.snackbar("نجاح", "تم حذف الموقع بنجاح");
      } else {
        isDeleting[locationId] = false;
        update();
        Get.snackbar("خطأ", "فشل في حذف الموقع");
      }
    } catch (e) {
      isDeleting[locationId] = false;
      update();
      Get.snackbar("خطأ", "حدث خطأ أثناء الحذف");
      debugPrint("خطأ في الحذف: $e");
    }
  }
}
