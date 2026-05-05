// ignore: file_names
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/views/Auth/User_SignUp/finish_signUp.dart';
import 'package:piaggio_driver/views/Auth/login_screen.dart';
import 'auth_controller.dart';

class OtpVerifySignupController extends GetxController {
  late TextEditingController codecontroller = TextEditingController();
  final AuthController controller = Get.find();
  final verfiykey = GlobalKey<FormState>();
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
      errorMessage.value = "";
      successMessage.value = "";
      final phone = controller.phoneCtrl.text.isNotEmpty
          ? controller.phoneCtrl.text
          : controller.phonecache.value;
      final result = await controller.sendOtp(phone: phone);
      if (result == null) {
        successMessage.value = "تم إرسال الرمز بنجاح";
        startTimer();
      } else {
        errorMessage.value = result;
      }
    }
  }

  Future<String?> otpVerifySignupController() async {
    bool isValidate = verfiykey.currentState!.validate();
    if (isValidate) {
      try {
        isLoading.value = true;
        // استخدام الرقم من phoneCtrl أو من phonecache عند القدوم من تسجيل الدخول
        final phone = controller.phoneCtrl.text.isNotEmpty
            ? controller.phoneCtrl.text
            : controller.phonecache.value;
        var data = {
          'phone': phone,
          'otp_code': codecontroller.text,
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
          final isFromLogin = controller.getStorage.read<bool>('from_login_flow') ?? false;
          controller.getStorage.remove('from_login_flow'); // تنظيف العلامة
          
          if (isFromLogin) {
            // جاء من تسجيل الدخول - الحساب تم تفعيله، يمكنه الآن تسجيل الدخول
            Get.offAll(() => LoginScreen());
            Get.snackbar(
              'تم التفعيل ✅',
              'تم تفعيل حسابك بنجاح، يرجى تسجيل الدخول الآن',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
            );
          } else {
            // جاء من التسجيل الجديد
            Get.to(() => const FinishSignup());
          }
          return null;
        } else {
          try {
            final data = jsonDecode(response.body);
            return data['message'] ?? "عملية التحقق غير صحيحة";
          } catch (_) {
            return "عملية التحقق غير صحيحة";
          }
        }
      } catch (e) {
        return "حدث خطأ أثناء التحقق: $e";
      } finally {
        isLoading.value = false;
      }
    }
    return "الرجاء إدخال رمز التحقق";
  }
}
