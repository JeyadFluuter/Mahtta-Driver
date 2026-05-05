import 'package:biadgo/logic/controller/change_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        appBar: AppBar(
          backgroundColor: Get.theme.primaryColor,
          title: const Text("تغيير كلمة المرور"),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.grey.shade100,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Form(
                  key: changePasswordController.confirmpasswordfromKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'قم بتحديث كلمة مرورك بانتظام لضمان أمان حسابك.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // حقل كلمة المرور القديمة
                      _buildPasswordField(
                        controller: changePasswordController.passwordOldCtrl,
                        hint: 'كلمة المرور الحالية',
                        isHiddenObs: changePasswordController.isPasswordHidden,
                        toggleCallback: changePasswordController.togglePasswordVisibility,
                        validator: (value) {
                          if (value == null || value.isEmpty) return "يرجى إدخال كلمة المرور الحالية";
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // حقل كلمة المرور الجديدة
                      _buildPasswordField(
                        controller: changePasswordController.passwordNewCtrl,
                        hint: 'كلمة المرور الجديدة',
                        isHiddenObs: changePasswordController.isPasswordHidden1,
                        toggleCallback: changePasswordController.togglePasswordVisibility1,
                        validator: (value) {
                          if (value == null || value.isEmpty) return "يرجى إدخال كلمة المرور الجديدة";
                          if (value.length < 6) return "كلمة المرور يجب أن تكون 6 أحرف على الأقل";
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // حقل تأكيد كلمة المرور الجديدة
                      _buildPasswordField(
                        controller: changePasswordController.passwordConfirmCtrl,
                        hint: 'تأكيد كلمة المرور الجديدة',
                        isHiddenObs: changePasswordController.isPasswordHidden2,
                        toggleCallback: changePasswordController.togglePasswordVisibility2,
                        validator: (value) {
                          if (value == null || value.isEmpty) return "يرجى تأكيد كلمة المرور الجديدة";
                          if (value != changePasswordController.passwordNewCtrl.text) {
                            return "كلمات المرور غير متطابقة";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 48),

                      // زر تأكيد
                      Center(
                        child: Obx(() => Button(
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
                          size: const Size(double.infinity, 56),
                        )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required RxBool isHiddenObs,
    required VoidCallback toggleCallback,
    String? Function(String?)? validator,
  }) {
    return Obx(() => TextFormField(
      controller: controller,
      obscureText: isHiddenObs.value,
      textAlign: TextAlign.right,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        prefixIcon: IconButton(
          icon: Icon(
            isHiddenObs.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey.shade400,
            size: 20,
          ),
          onPressed: toggleCallback,
        ),
        suffixIcon: Icon(
          Icons.lock_outline,
          color: Get.theme.primaryColor.withOpacity(0.7),
          size: 22,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Get.theme.primaryColor, width: 1.5),
        ),
        errorStyle: const TextStyle(fontSize: 12),
      ),
    ));
  }
}
