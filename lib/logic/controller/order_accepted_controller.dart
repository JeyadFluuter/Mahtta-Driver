import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/logic/controller/location_controller.dart';
import 'package:piaggio_driver/logic/controller/order_request_controller.dart';
import 'package:piaggio_driver/services/order_accepted_services.dart';
import 'package:piaggio_driver/views/order_accepted_screen.dart';
import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:piaggio_driver/logic/controller/wallet_controller.dart';

import 'package:piaggio_driver/logic/controller/rejection_order_controller.dart';

class OrderAcceptedController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxInt _orderId = 0.obs;
  int get orderId => _orderId.value;

  void setOrderId(int id) => _orderId.value = id;
  void rejectCurrentOrder() => _orderId.value = 0;

  Future<void> orderAccepted() async {
    if (isLoading.value) return;
    debugPrint("🚀 orderAccepted() START orderId=$orderId");

    if (orderId == 0) {
      Get.snackbar("تنبيه", "رقم الطلب غير صالح", backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      // 1. Force refresh wallet balance for accurate check
      final walletCtrl = Get.isRegistered<WalletController>()
          ? Get.find<WalletController>()
          : Get.put(WalletController());
      
      await walletCtrl.fetchData();

      final orderCtrl = Get.isRegistered<OrderController>()
          ? Get.find<OrderController>()
          : Get.put(OrderController());

      final currentOrder = orderCtrl.currentOrder.value;

      if (currentOrder != null && currentOrder.id == orderId) {
        double commission = double.tryParse(currentOrder.commissionLyd) ?? 0.0;
        double balance = double.tryParse(walletCtrl.wallet.value?.balance ?? "0") ?? 0.0;

        if (commission > balance) {
          // Logic for insufficient balance (already implemented dialog)
          _showInsufficientBalanceDialog(commission, balance);
          return;
        }
      }

      // 2. Ensure Location is ready
      final locCtrl = Get.isRegistered<LocationController>()
          ? Get.find<LocationController>()
          : Get.put(LocationController(), permanent: true);

      final loc = await locCtrl.ensureLastLocation();
      final double? lat = loc?.latitude ?? locCtrl.lastLat;
      final double? lng = loc?.longitude ?? locCtrl.lastLng;

      if (lat == null || lng == null) {
        Get.snackbar("تنبيه", "يجب تفعيل الـ GPS لتتمكن من قبول الطلب", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final data = {
        'order_id': orderId,
        'current_lat': lat,
        'current_lng': lng,
      };

      final token = GetStorage().read<String>('token') ?? '';
      final response = await http.post(
        Uri.parse('$apiUrl/orders/accept-order'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        // Clear current offer
        try {
          final orderCtrl = Get.find<OrderController>();
          orderCtrl.clearCurrentOrder();
          GetStorage().remove('latest_order_id');
        } catch (_) {}

        // Initialize tracking screen services
        await OrderAcceptedServices().init(orderId);
        
        // START LOCATION TRACKING IMMEDIATELY
        locCtrl.startLocationTimer();

        Get.offAll(() => OrderAcceptedScreen(orderId: orderId));
      } else {
        final errorMsg = json.decode(response.body)['message'] ?? "لم يتم قبول الطلب من السيرفر";
        Get.snackbar("فشل العملية", errorMsg, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('❌ orderAccepted error: $e');
      Get.snackbar("خطأ", "حدث خطأ غير متوقع، يرجى المحاولة لاحقاً", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void _showInsufficientBalanceDialog(double commission, double balance) {
    // Moved the complex dialog logic here to keep orderAccepted clean
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppThemes.primaryOrange.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.account_balance_wallet_rounded, color: AppThemes.primaryOrange, size: 40),
              ),
              const SizedBox(height: 24),
              const Text("رصيدك غير كافي", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppThemes.primaryNavy)),
              const SizedBox(height: 16),
              Text("لا يمكنك قبول هذا الطلب لأن عمولته ($commission د.ل) أكبر من رصيدك الحالي ($balance د.ل).",
                  textAlign: TextAlign.center, style: TextStyle(color: AppThemes.primaryNavy.withOpacity(0.7), fontSize: 14, height: 1.5)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppThemes.primaryNavy, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text("موافق", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
