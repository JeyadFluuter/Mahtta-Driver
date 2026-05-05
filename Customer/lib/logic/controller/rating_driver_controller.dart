// lib/logic/controller/rating_driver_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/rating_driver_services.dart';

class RateDriverController extends GetxController {
  final commentController = TextEditingController();
  final rating = 0.obs;
  final isLoading = false.obs;

  late final RatingService _service;
  @override
  void onInit() {
    super.onInit();
    _service = Get.find<RatingService>();
  }

  Future<void> ratingDriver(
      {required int orderId, required BuildContext context}) async {
    isLoading(true);
    try {
      final res = await _service.ratingDriver(
        orderId: orderId,
        rating: rating.value.toString(),
        comment: commentController.text,
      );
      if (res != null && res.error == 0) {
        Get.snackbar(
          'نجاح',
          'تم التقييم',
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
          icon: const Icon(
            Icons.check,
          ),
        );
        Navigator.of(context).pop(); // إغلاق BottomSheet
      } else {
        Get.snackbar(
          'خطأ',
          res?.message ?? 'فشل غير متوقع',
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          icon: const Icon(
            Icons.error,
          ),
        );
      }
    } catch (e) {
      Get.snackbar('خطأ في الاتصال', e.toString());
      debugPrint("خطأ في الاتصال: $e");
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}
