import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:piaggio_driver/services/forgot_password_services.dart';
import 'package:piaggio_driver/views/Auth/otp_forgot_password_screen.dart';

class ForgotPasswordController extends GetxController {
  final ForgotPasswordServices forgotPasswordServices =
      ForgotPasswordServices();

  final changephonefromKey = GlobalKey<FormState>();
  final GetStorage getStorage = GetStorage();
  final TextEditingController phoneCtrl = TextEditingController();
  RegExp phoneNumberPattern = RegExp(r'^(091|092|093|094)\d{7}$');
  String? phonecachee;
  final isLoading = false.obs;

  final errorMessage = "".obs;
  final successMessage = "".obs;

  Future<void> forgotPassword({required String phone}) async {
    bool isValidate = changephonefromKey.currentState!.validate();
    if (!isValidate) return;

    errorMessage.value = "";
    successMessage.value = "";

    try {
      isLoading.value = true;
      debugPrint("🚀 الرقم المدخل: $phone");
      final error = await forgotPasswordServices.changePhone(phone: phone);
      if (error == null) {
        phonecachee = phone;
        phoneCtrl.text = phone;
        getStorage.write('phonecache', phonecachee);
        debugPrint(
            "✅ تم تخزين الرقم في GetStorage: ${getStorage.read('phonecache')}");
        Get.to(() => OtpForgotPasswordScreen());
      } else {
        errorMessage.value = error;
      }
    } catch (e) {
      debugPrint("❌ خطأ أثناء تغيير الرقم: $e");
      errorMessage.value = "حدث خطأ غير متوقع، يرجى المحاولة لاحقاً";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetSendOtp({required String phone}) async {
    errorMessage.value = "";
    successMessage.value = "";

    try {
      isLoading.value = true;
      debugPrint("🚀 الرقم المدخل: $phone");
      final error = await forgotPasswordServices.changePhone(phone: phone);
      if (error == null) {
        phonecachee = phone;
        phoneCtrl.text = phone;
        getStorage.write('phonecache', phonecachee);
        debugPrint(
            "✅ تم تخزين الرقم في GetStorage: ${getStorage.read('phonecache')}");

        successMessage.value = "تم إرسال رمز التحقق بنجاح";
      } else {
        errorMessage.value = error;
      }
    } catch (e) {
      debugPrint("❌ خطأ أثناء تغيير الرقم: $e");
      errorMessage.value = "حدث خطأ غير متوقع، يرجى المحاولة لاحقاً";
    } finally {
      isLoading.value = false;
    }
  }
}
