import 'package:biadgo/models/change_phone_model.dart';
import 'package:biadgo/services/forgot_password_services.dart';
import 'package:biadgo/views/Auth/otp_forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ForgotPasswordController extends GetxController {
  final ForgotPasswordServices forgotPasswordServices =
      ForgotPasswordServices();
  final changephonefromKey = GlobalKey<FormState>();
  final GetStorage getStorage = GetStorage();
  final TextEditingController phoneCtrl = TextEditingController();
  RegExp phoneNumberPattern = RegExp(r'^(091|092|093|094)\d{7}$');
  var changePhone = Rxn<ChangePhoneModel>();
  String? phonecachee;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> forgotPassword({required String phone}) async {
    bool isValidate = changephonefromKey.currentState!.validate();
    if (!isValidate) return;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      debugPrint("🚀 الرقم المدخل: $phone");
      final result = await forgotPasswordServices.changePhone(phone: phone);

      if (result['success'] == true) {
        phonecachee = phone;
        phoneCtrl.text = phone;
        getStorage.write('phonecache', phonecachee);
        debugPrint(
            "✅ تم تخزين الرقم في GetStorage: ${getStorage.read('phonecache')}");

        Get.snackbar(
          "إرسال رمز تحقق",
          "تم إرسال رمز التحقق بنجاح",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.check, color: Colors.white),
        );
        Get.to(() => OtpForgotPasswordScreen());
      } else {
        errorMessage.value = result['message'] ?? "حدث خطأ في الخادم، يرجى المحاولة لاحقاً";
      }
    } catch (e) {
      debugPrint("❌ خطأ أثناء تغيير الرقم: $e");
      errorMessage.value = "حدث خطأ في الخادم، يرجى المحاولة لاحقاً";
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resendOtp({required String phone}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      debugPrint("🚀 الرقم المدخل لإعادة الإرسال: $phone");
      final result = await forgotPasswordServices.changePhone(phone: phone);

      if (result['success'] == true) {
        phonecachee = phone;
        phoneCtrl.text = phone;
        getStorage.write('phonecache', phonecachee);
        debugPrint(
            "✅ تم تخزين الرقم في GetStorage: ${getStorage.read('phonecache')}");

        Get.snackbar(
          "إرسال رمز تحقق",
          "تم إرسال رمز التحقق بنجاح",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.check, color: Colors.white),
        );
        return true;
      } else {
        errorMessage.value = result['message'] ?? "حدث خطأ في الخادم، يرجى المحاولة لاحقاً";
        return false;
      }
    } catch (e) {
      debugPrint("❌ خطأ أثناء إعادة إرسال الرمز: $e");
      errorMessage.value = "حدث خطأ في الخادم، يرجى المحاولة لاحقاً";
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
