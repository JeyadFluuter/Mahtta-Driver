import 'dart:convert';
import 'package:biadgo/constants/apiUrl.dart';
import 'package:biadgo/logic/controller/my_order_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class CancelOrderServices {
  /// يرسل طلب إلغاء الطلب إلى السيرفر
  Future<bool> cancelOrder(int orderId) async {
    try {
      final token = GetStorage().read('token') as String?;
      if (token == null) return false;

      final res = await http.post(
        Uri.parse('$apiUrl/orders/order/$orderId/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));


      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final success = body['error'] == 0 || body['status'] == 'success';
        if (success) {
          if (Get.isRegistered<MyOrderController>()) {
            Get.find<MyOrderController>().latestActiveOrder.value = null;
          }
        }
        return success;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
