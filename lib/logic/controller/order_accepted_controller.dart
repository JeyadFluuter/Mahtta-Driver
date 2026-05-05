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
  final RxInt _orderId = 0.obs;
  int get orderId => _orderId.value;

  void setOrderId(int id) => _orderId.value = id;
  void rejectCurrentOrder() => _orderId.value = 0;

  Future<void> orderAccepted() async {
    debugPrint("🚀 orderAccepted() START orderId=$orderId");

    if (orderId == 0) {
      Get.snackbar("خطأ", "رقم الطلب غير موجود");
      return;
    }

    try {
      // 1. Check wallet balance vs commission
      final walletCtrl = Get.isRegistered<WalletController>()
          ? Get.find<WalletController>()
          : Get.put(WalletController());

      // Ensure wallet data is fetched
      if (walletCtrl.wallet.value == null) {
        await walletCtrl.fetchData();
      }

      final orderCtrl = Get.isRegistered<OrderController>()
          ? Get.find<OrderController>()
          : Get.put(OrderController());

      final currentOrder = orderCtrl.currentOrder.value;

      if (currentOrder != null && currentOrder.id == orderId) {
        double commission = double.tryParse(currentOrder.commissionLyd) ?? 0.0;
        double balance =
            double.tryParse(walletCtrl.wallet.value?.balance ?? "0") ?? 0.0;

        if (commission > balance) {
          // Reject order so it disappears from UI
          final rejectCtrl = Get.isRegistered<RejectionOrderController>()
              ? Get.find<RejectionOrderController>()
              : Get.put(RejectionOrderController());
          rejectCtrl.rejectOrder(orderId: orderId);

          Get.dialog(
            Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: Offset(0.0, 10.0)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppThemes.primaryOrange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded,
                          color: AppThemes.primaryOrange, size: 40),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "رصيدك غير كافي",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppThemes.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "لا يمكنك قبول هذا الطلب لأن عمولته ($commission د.ل) أكبر من رصيدك الحالي ($balance د.ل).",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppThemes.primaryNavy.withOpacity(0.7),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: Builder(builder: (context) {
                        return ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppThemes.primaryNavy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          child: const Text(
                            "موافق",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          );
          return;
        }
      }

      final locCtrl = Get.isRegistered<LocationController>()
          ? Get.find<LocationController>()
          : Get.put(LocationController(), permanent: true);

      final loc = await locCtrl.ensureLastLocation();
      final double? lat = loc?.latitude ?? locCtrl.lastLat;
      final double? lng = loc?.longitude ?? locCtrl.lastLng;

      if (lat == null || lng == null) {
        Get.snackbar(
          "تنبيه",
          "تعذر تحديد موقعك الحالي. جرّب تفعيل GPS ثم أعد المحاولة.",
        );
        return;
      }

      final data = <String, dynamic>{
        'order_id': orderId,
        'current_lat': lat,
        'current_lng': lng,
      };

      final token = GetStorage().read<String>('token') ?? '';
      if (token.isEmpty) {
        Get.snackbar("خطأ", "التوكن غير موجود، سجل دخول من جديد");
        return;
      }
      debugPrint(
          "✅ Accepting orderId=$orderId lat=$lat lng=$lng token=$token ");

      final response = await http.post(
        Uri.parse('$apiUrl/orders/accept-order'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(data),
      );
      debugPrint(
          "❌ accept status=${response.statusCode} body=${response.body}");

      if (response.statusCode == 200) {
        Get.snackbar(
          "نجاح",
          "تم قبول الطلب بنجاح",
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.check),
        );

        try {
          final orderCtrl = Get.isRegistered<OrderController>()
              ? Get.find<OrderController>()
              : null;
          orderCtrl?.clearCurrentOrder();
        } catch (_) {}

        try {
          GetStorage().remove('latest_order_id');
        } catch (_) {}

        await OrderAcceptedServices().init(orderId);
        Get.offAll(() => OrderAcceptedScreen(orderId: orderId));
      } else {
        Get.snackbar(
          "فشل",
          "لم يتم قبول الطلب",
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.error),
        );
      }
    } catch (e) {
      Get.snackbar("خطأ", "حدث خطأ أثناء إرسال الطلب");
      debugPrint('❌ orderAccepted error: $e');
    }
  }
}
