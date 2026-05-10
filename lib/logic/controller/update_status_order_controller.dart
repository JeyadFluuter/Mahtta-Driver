import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/logic/controller/order_tracking_controller.dart';
import 'package:piaggio_driver/model/order_data_model.dart';

class UpdateStatusOrderController extends GetxController {
  final OrderTrackingController _track = Get.find<OrderTrackingController>();
  final RxBool isLoading = false.obs;
  final RxString optimisticName = ''.obs;

  final Map<int, String> _nextStatusNames = {
    3: 'في طريقي لنقطة الاستلام (A)',
    4: 'وصلت لنقطة الاستلام (A)',
    5: 'جاري التوصيل للوجهة (B)',
    6: 'وصلت للوجهة (B)',
  };

  Future<void> updateStatus() async {
    final orderResp = _track.orderResponse.value;
    if (orderResp == null) {
      log('⚠️ لا يوجد طلب حالياً لتحديث حالته');
      return;
    }

    final nextId = orderResp.status.id + 1;
    optimisticName.value = _nextStatusNames[nextId] ?? '';

    final data = {
      'order_id': orderResp.order.id,
      'status_id': nextId,
    };

    isLoading.value = true;
    try {
      final token = GetStorage().read('token');
      final response = await http.put(
        Uri.parse('$apiUrl/orders/update-status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final js = json.decode(response.body);
        if (js['data'] != null) {
          _track.setOrderResponse(OrderResponse.fromJson(js['data']));
        }
        log('✅ تم تحديث الحالة بنجاح');
      } else {
        log('❌ فشل تحديث الحالة: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ UpdateStatusOrderController Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
