import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/logic/controller/forgot_password_controller.dart';
import 'package:piaggio_driver/views/Auth/change_password_welcome_screen.dart';

class OtpVerifyForgotPasswordController extends GetxController {
  late TextEditingController codecontroller = TextEditingController();
  final ForgotPasswordController controller = Get.find();
  final verfiyykey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final RxString errorMessage = "".obs;
  final RxString successMessage = "".obs;

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
      await controller.resetSendOtp(phone: controller.phoneCtrl.text.trim());
      if (controller.errorMessage.value.isEmpty) {
        startTimer();
      }
    }
  }

  Future<void> otpVerifyforgotpassword() async {
    if (!verfiyykey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = "";
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
        Get.to(() => ChangePasswordWelcomeScreen());
      } else {
        errorMessage.value = "رمز التحقق غير صحيح، يرجى المحاولة مرة أخرى";
      }
    } catch (e) {
      debugPrint('❌ $e');
      errorMessage.value = "حدث خطأ أثناء التحقق، يرجى المحاولة لاحقاً";
    } finally {
      isLoading.value = false;
    }
  }
}
