import 'dart:async';
import 'dart:convert';
import 'package:biadgo/constants/apiUrl.dart';
import 'package:biadgo/logic/controller/forgot_password_controller.dart';
import 'package:biadgo/views/Auth/User_SignUp/finish_signUp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'auth_controller.dart';

class OtpVerifySignupController extends GetxController {
  late TextEditingController codecontroller = TextEditingController();
  final AuthController controller = Get.find();
  final ForgotPasswordController forgotCtrl = Get.find();
  final verfiykey = GlobalKey<FormState>();

  // Timer logic
  Timer? _timer;
  var timerValue = 180.obs; // 3 minutes
  var isTimerFinished = false.obs;
  var isLoading = false.obs;

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

  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  Future<void> resendOtp() async {
    errorMessage.value = '';
    successMessage.value = '';
    if (isTimerFinished.value) {
      final bool successfulResend =
          await forgotCtrl.resendOtp(phone: controller.phoneCtrl.text.trim());
      if (successfulResend) {
        successMessage.value = "تم إعادة إرسال رمز التحقق بنجاح.";
        startTimer();
      } else {
        errorMessage.value = "فشل إعادة إرسال الرمز، حاول مرة أخرى.";
      }
    }
  }

  Future<String?> otpVerifySignupController() async {
    bool isValidate = verfiykey.currentState!.validate();
    if (isValidate) {
      try {
        isLoading.value = true;
        errorMessage.value = '';
        successMessage.value = '';
        var data = {
          'phone': controller.phoneCtrl.text.trim(),
          'otp_code': codecontroller.text.trim(),
        };

        var response = await http.put(
          Uri.parse('$apiUrl/verify-otp'),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: json.encode(data),
        );

        if (response.statusCode == 200) {
          Get.offAll(() => const FinishSignup()); // Use offAll to clean stack
          return null;
        } else {
          try {
            final Map<String, dynamic> responseData = jsonDecode(response.body);
            errorMessage.value = responseData['message'] ?? "رمز التحقق غير صحيح.";
            return errorMessage.value;
          } catch (_) {
            errorMessage.value = "رمز التحقق غير صحيح، يرجى المحاولة مرة أخرى.";
            return errorMessage.value;
          }
        }
      } catch (e) {
        errorMessage.value = "حدث خطأ غير متوقع: $e";
        return errorMessage.value;
      } finally {
        isLoading.value = false;
      }
    }
    return "الرجاء إدخال الرمز بشكل صحيح.";
  }
}
