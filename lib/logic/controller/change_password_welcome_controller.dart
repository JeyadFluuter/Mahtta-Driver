import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:piaggio_driver/logic/controller/forgot_password_controller.dart';
import 'package:piaggio_driver/model/change_password_welcome_model.dart';
import 'package:piaggio_driver/services/change_password_welcome_services.dart';
import 'package:piaggio_driver/views/Auth/login_screen.dart';

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

    try {
      final result = await changePasswordWelcomeServices.resetPassword(
        phone: controller.phoneCtrl.text,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (result != null) {
        Get.snackbar("تسجيل الدخول", "عملية تسجيل الدخول صحيحة");
        changePasswordWelcomeModel.value = result;
        Get.offAll(() => LoginScreen());
      } else {
        Get.snackbar("تسجيل الدخول", "هناك خطأ في عملية تسجيل الدخول  ");
      }
    } catch (e) {
      debugPrint('❌‏ $e');
    }
  }
}
