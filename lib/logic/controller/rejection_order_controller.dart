// 📁 logic/controller/rejection_order_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:piaggio_driver/logic/controller/order_accepted_controller.dart';
import 'package:piaggio_driver/logic/controller/order_request_controller.dart';
import 'package:piaggio_driver/services/order_request_services.dart';
import 'package:piaggio_driver/services/rejection_order_services.dart';

class RejectionOrderController extends GetxController {
  final _svc = RejectionOrderServices();
  final _box = GetStorage();

  final OrderAcceptedController acceptedCtrl =
      Get.isRegistered<OrderAcceptedController>()
          ? Get.find<OrderAcceptedController>()
          : Get.put(OrderAcceptedController(), permanent: true);

  final OrderController? orderCtrl =
      Get.isRegistered<OrderController>() ? Get.find<OrderController>() : null;

  final RxBool isLoading = false.obs;

  int _resolveOrderId({int? explicitId}) {
    if (explicitId != null && explicitId > 0) return explicitId;

    final fromAccepted = acceptedCtrl.orderId;
    if (fromAccepted != 0) return fromAccepted;

    try {
      final current = orderCtrl?.currentOrder.value;
      if (current != null) {
        return current.id;
      }
    } catch (_) {}

    final latest = _box.read('latest_order_id');
    if (latest is int && latest > 0) return latest;
    if (latest is String) {
      final p = int.tryParse(latest) ?? 0;
      if (p > 0) return p;
    }
    return 0;
  }

  Future<void> rejectCurrentOrder() async {
    await rejectOrder();
  }

  Future<void> rejectOrder({int? orderId}) async {
    if (isLoading.value) return;

    final oid = _resolveOrderId(explicitId: orderId);
    if (oid == 0) {
      Get.snackbar('خطأ', 'لا يوجد طلب نشط لرفضه');
      return;
    }

    isLoading.value = true;
    try {
      final res = await _svc.rejectOrder(orderId: oid);
      if (res != null) {
        acceptedCtrl.rejectCurrentOrder();
        _clearCurrentOrderCard();

        _closeOverlayIfAny();

        Get.snackbar(
          'تم الرفض',
          'تم رفض الطلب #$oid بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check, color: Colors.white),
          duration: const Duration(seconds: 2),
        );

        try {
          await Get.find<PusherService>().ensureConnected();
        } catch (e) {
          debugPrint('❌ تعذّر إعادة الاشتراك بالقناة: $e');
        }
      } else {
        Get.snackbar(
          'خطأ',
          'تعذّر رفض الطلب #$oid',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء رفض الطلب: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _clearCurrentOrderCard() {
    try {
      orderCtrl?.currentOrder.value = null;
    } catch (_) {}
    _box.remove('latest_order_id');
  }

  void _closeOverlayIfAny() {
    if (Get.isDialogOpen == true) {
      Get.back();
    } else if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
  }
}
