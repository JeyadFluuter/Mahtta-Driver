import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/logic/controller/change_password_screen_controller.dart';
import '../../constants/app_dimensions.dart';
import '../../widgets/button.dart';

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});
  final ChangePasswordController changePasswordController =
      Get.put(ChangePasswordController());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFBFBFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "تغيير كلمة المرور",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppThemes.primaryNavy,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: AppThemes.primaryNavy, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: changePasswordController.confirmpasswordfromKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // Instruction Text
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "قم بتحديث كلمة مرورك بانتظام لضمان أمان حسابك.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black45,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Current Password
                  _buildPasswordField(
                    controller: changePasswordController.passwordOldCtrl,
                    hint: "كلمة المرور الحالية",
                    isHidden: changePasswordController.isPasswordHidden,
                    toggle: changePasswordController.togglePasswordVisibility,
                    validator: (value) {
                      if (value!.isEmpty) return "الرجاء إدخال كلمة المرور";
                      if (value.length < 6) return "كلمة المرور قصيرة جداً";
                      return null;
                    },
                  ),

                  // New Password
                  _buildPasswordField(
                    controller: changePasswordController.passwordNewCtrl,
                    hint: "كلمة المرور الجديدة",
                    isHidden: changePasswordController.isPasswordHidden1,
                    toggle: changePasswordController.togglePasswordVisibility1,
                    validator: (value) {
                      if (value!.isEmpty) return "الرجاء إدخال كلمة المرور";
                      if (value.length < 6) return "كلمة المرور قصيرة جداً";
                      return null;
                    },
                  ),

                  // Confirm Password
                  _buildPasswordField(
                    controller: changePasswordController.passwordConfirmCtrl,
                    hint: "تأكيد كلمة المرور الجديدة",
                    isHidden: changePasswordController.isPasswordHidden2,
                    toggle: changePasswordController.togglePasswordVisibility2,
                    validator: (value) {
                      if (value!.isEmpty) return "الرجاء إدخال تأكيد كلمة المرور";
                      if (value != changePasswordController.passwordNewCtrl.text) {
                        return "كلمة المرور غير متطابقة";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 60),

                  // Save Button
                  Obx(() => Button(
                        name: 'حفظ كلمة المرور الجديدة',
                        isLoading: changePasswordController.isLoading.value,
                        onPressed: () {
                          if (changePasswordController.confirmpasswordfromKey.currentState!.validate()) {
                            changePasswordController.ChangePassword(
                              oldPassword: changePasswordController.passwordOldCtrl.text.trim(),
                              password: changePasswordController.passwordNewCtrl.text.trim(),
                              passwordConfirmation: changePasswordController.passwordConfirmCtrl.text.trim(),
                            );
                          }
                        },
                        size: Size(
                          AppDimensions.screenWidth * 0.55,
                          50,
                        ),
                      )),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required RxBool isHidden,
    required VoidCallback toggle,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Obx(
        () => TextFormField(
          controller: controller,
          obscureText: isHidden.value,
          validator: validator,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFFB057), size: 22),
            suffixIcon: IconButton(
              icon: Icon(
                isHidden.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.black26,
                size: 20,
              ),
              onPressed: toggle,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFF1F1F1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFF1F1F1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: AppThemes.primaryNavy.withOpacity(0.5)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ),
    );
  }
}

