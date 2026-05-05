// 📁 logic/controller/splash_controller.dart
import 'package:biadgo/logic/controller/refresh_token_controller.dart';
import 'package:biadgo/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SplashController extends GetxController {
  final GetStorage getStorage = GetStorage();
  @override
  void onReady() async {
    super.onReady();
    await Future.delayed(const Duration(seconds: 3));

    final refreshCtrl = Get.find<RefreshTokenController>();
    final String? accessExpires = getStorage.read('accessExpires') as String?;
    final String? token = getStorage.read('token') as String?;

    if (accessExpires == null || token == null) {
      debugPrint('[SPLASH] لا توجد توكنات، اذهب إلى شاشة الترحيب');
      _goToWelcome();
      return;
    }

    final expiry = DateTime.parse(accessExpires);
    final refreshAt = expiry.subtract(const Duration(minutes: 5));
    final nowUtc = DateTime.now().toUtc();

    if (nowUtc.isBefore(refreshAt)) {
      debugPrint('[SPLASH] التوكن ما زال صالحاً، اذهب إلى الصفحة الرئيسية');
      refreshCtrl.reschedule();
      _goToHome();
      return;
    }

    debugPrint('[SPLASH] التوكن اقترب من الانتهاء أو انتهى، نجدد الآن');
    try {
      final newTok = await refreshCtrl
          .refreshNow()
          .timeout(const Duration(seconds: 3), onTimeout: () => null);
      if (newTok != null) {
        debugPrint('[SPLASH] تم التجديد بنجاح، اذهب إلى الصفحة الرئيسية');
        refreshCtrl.reschedule();
        _goToHome();
      } else {
        debugPrint('[SPLASH] فشل التجديد، اذهب إلى شاشة الترحيب');
        _goToWelcome();
      }
    } catch (e) {
      debugPrint('[SPLASH] خطأ أثناء التجديد: $e');
      _goToWelcome();
    }
  }

  void _goToHome() => Get.offAllNamed(AppRoutes.navbar);
  void _goToWelcome() => Get.offAllNamed(AppRoutes.welcomeScreen);
}
