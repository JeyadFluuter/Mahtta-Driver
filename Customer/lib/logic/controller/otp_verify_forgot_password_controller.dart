import 'dart:async';
import 'dart:convert';
import 'package:biadgo/constants/apiUrl.dart';
import 'package:biadgo/logic/controller/forgot_password_controller.dart';
import 'package:biadgo/views/Auth/change_password_welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class OtpVerifyForgotPasswordController extends GetxController {
  late TextEditingController codecontroller = TextEditingController();
  final ForgotPasswordController controller = Get.find();
  final verfiyykey = GlobalKey<FormState>();
  final GetStorage getStorage = GetStorage();

  // Timer logic
  Timer? _timer;
  var timerValue = 180.obs; // 3 minutes
  var isTimerFinished = false.obs;

  String get timerText {
    int minutes = timerValue.value ~/ 60;
    int seconds = timerValue.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void onReady() {
    super.onReady();
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startTimer() {
    isTimerFinished.value = false;
    timerValue.value = 180;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerValue.value > 0) {
        timerValue.value--;
      } else {
        isTimerFinished.value = true;
        _timer?.cancel();
      }
    });
  }

  Future<void> resendOtp() async {
    if (isTimerFinished.value) {
      await controller.resendOtp(phone: controller.phoneCtrl.text.trim());
      startTimer();
    }
  }

  Future<void> otpVerifyforgotpassword() async {
    if (!verfiyykey.currentState!.validate()) {
      return;
    }

    try {
      var data = {
        'phone': controller.phoneCtrl.text,
        'otp_code': codecontroller.text,
      };

      final token = GetStorage().read('token');
      var response = await http.put(
        Uri.parse('$apiUrl/verify_code'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        getStorage.write('otp_code', codecontroller.text);
        Get.snackbar("عملية التحقق", "عملية التحقق صحيحة",
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            icon: const Icon(Icons.check));
        Get.to(() => ChangePasswordWelcomeScreen());
      } else {
        Get.snackbar("عملية التحقق", "عملية التحقق غير صحيحة",
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            icon: const Icon(Icons.error));
      }
    } catch (e) {
      debugPrint("خطأ أثناء التحقق: $e");
      Get.snackbar("خطأ", "حدث خطأ أثناء التحقق");
    }
  }
}
