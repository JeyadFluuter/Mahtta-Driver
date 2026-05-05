import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:piaggio_driver/logic/controller/me_controller.dart';
import 'package:piaggio_driver/routes/routes.dart';
import 'package:flutter/widgets.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _decideNext();
    });
  }

  Future<void> _decideNext() async {
    await Future.delayed(const Duration(seconds: 3));
    final box = GetStorage();
    final token = box.read<String>('token') ?? '';
    if (token.isEmpty) {
      Get.offAllNamed(AppRoutes.welcomeScreen);
      return;
    }
    final me = Get.isRegistered<MeController>()
        ? Get.find<MeController>()
        : Get.put(MeController(), permanent: true);

    final ok = await me
        .refreshMe()
        .timeout(const Duration(seconds: 8), onTimeout: () => false);
    Get.offAllNamed(ok ? AppRoutes.homescreen : AppRoutes.welcomeScreen);
  }
}
