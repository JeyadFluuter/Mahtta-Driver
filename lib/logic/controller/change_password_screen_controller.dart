import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:piaggio_driver/model/change_password_screen_model.dart';
import 'package:piaggio_driver/routes/routes.dart';
import 'package:piaggio_driver/services/change_password_screen_services.dart';

class ChangePasswordController extends GetxController {
  final ChangePasswordServices changePasswordServices =
      ChangePasswordServices();
  final confirmpasswordfromKey = GlobalKey<FormState>();
  final GetStorage getStorage = GetStorage();
  RegExp phoneNumberPattern = RegExp(r'^(091|092|093|094)\d{7}$');
  final TextEditingController passwordOldCtrl = TextEditingController();
  final TextEditingController passwordNewCtrl = TextEditingController();
  final TextEditingController passwordConfirmCtrl = TextEditingController();
  var changePassword = Rxn<ChangePasswordModel>();
  var isPasswordHidden = true.obs;
  var isPasswordHidden1 = true.obs;
  var isPasswordHidden2 = true.obs;
  final isLoading = false.obs;
  //
  // ignore: non_constant_identifier_names
  Future<void> ChangePassword({
    required String oldPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    bool isValidate = confirmpasswordfromKey.currentState!.validate();
    if (!isValidate) {
      return;
    }
    try {
      isLoading.value = true;
      final result = await changePasswordServices.changePassword(
        oldPassword: oldPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      if (result != null) {
        Get.snackbar("تغيير كلمة المرور", "تم تغيير كلمة المرور بنجاح",
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            icon: const Icon(Icons.check));
        changePassword.value = result;
        Get.offAllNamed(AppRoutes.homescreen);
      } else {
        Get.snackbar(
            "تغيير كلمة المرور", "هناك خطأ في عملية تغيير كلمة المرور  ",
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            icon: const Icon(Icons.error));
      }
    } catch (e) {
      debugPrint('❌‏ $e');
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void togglePasswordVisibility1() {
    isPasswordHidden1.value = !isPasswordHidden1.value;
  }

  void togglePasswordVisibility2() {
    isPasswordHidden2.value = !isPasswordHidden2.value;
  }
}
