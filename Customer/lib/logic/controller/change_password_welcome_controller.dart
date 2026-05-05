import 'package:biadgo/logic/controller/forgot_password_controller.dart';
import 'package:biadgo/models/change_password_welcome_model.dart';
import 'package:biadgo/services/change_password_welcome_services.dart';
import 'package:biadgo/views/Auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ChangePasswordWelcomeController extends GetxController {
  final ChangePasswordWelcomeServices changePasswordWelcomeServices =
      ChangePasswordWelcomeServices();
  final confirmpassworddfromKey = GlobalKey<FormState>();
  final GetStorage getStorage = GetStorage();
  final TextEditingController passwordNewCtrl = TextEditingController();
  final TextEditingController passwordConfirmCtrl = TextEditingController();
  var changePasswordWelcomeModel = Rxn<ChangePasswordWelcomeModel>();
  final ForgotPasswordController controller = Get.find();

  Future<void> resetPassword({
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    bool isValidate = confirmpassworddfromKey.currentState!.validate();
    if (!isValidate) {
      return;
    }
    final String? otpCode = getStorage.read('otp_code');

    try {
      final result = await changePasswordWelcomeServices.resetPassword(
        phone: controller.phoneCtrl.text,
        password: password,
        confirmPassword: confirmPassword,
        otpCode: otpCode!,
      );

      if (result != null) {
        Get.snackbar("تغيير كلمة المرور", "تم تغيير كلمة المرور بنجاح",
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            icon: const Icon(Icons.check));
        changePasswordWelcomeModel.value = result;
        getStorage.remove('otp_code');
        Get.offAll(() => LoginScreen());
      } else {
        Get.snackbar(
            "تغيير كلمة المرور", "هناك خطأ في عملية تغيير كلمة المرور  ",
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            icon: const Icon(Icons.error));
      }
    } catch (e) {
      debugPrint('خطأ أثناء تغيير كلمة المرور: $e');
    }
  }
}
