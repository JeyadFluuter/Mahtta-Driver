import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:piaggio_driver/logic/controller/change_password_welcome_controller.dart';
import '../../constants/app_dimensions.dart';
import '../../widgets/button.dart';

class ChangePasswordWelcomeScreen extends StatelessWidget {
  ChangePasswordWelcomeScreen({super.key});
  final ChangePasswordWelcomeController changePasswordWelcomeController =
      Get.put(ChangePasswordWelcomeController());

  @override
  Widget build(BuildContext context) {
    final h = AppDimensions.screenHeight;
    final w = AppDimensions.screenWidth;

    return Scaffold(
      backgroundColor: AppThemes.light.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppThemes.light.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left_rounded, color: Colors.black, size: 30),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.07),
            child: Form(
              key: changePasswordWelcomeController.confirmpassworddfromKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  SizedBox(height: h * 0.02),
                  Image.asset(
                    'assets/images/piaggio22.png',
                    height: h * 0.18,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'تغيير كلمة المرور',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'أدخل كلمة المرور الجديدة وقم بتأكيدها للمتابعة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildTextField(
                    controller: changePasswordWelcomeController.passwordNewCtrl,
                    hint: 'كلمة المرور الجديدة',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "الرجاء إدخال كلمة المرور";
                      if (value.length < 6) return "كلمة المرور قصيرة جداً";
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: changePasswordWelcomeController.passwordConfirmCtrl,
                    hint: 'تأكيد كلمة المرور الجديدة',
                    icon: Icons.lock_reset_outlined,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "الرجاء تأكيد كلمة المرور";
                      if (value != changePasswordWelcomeController.passwordNewCtrl.text) {
                        return "كلمات المرور غير متطابقة";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: h * 0.065,
                    child: Button(
                      name: 'تأكيد',
                      onPressed: () {
                        changePasswordWelcomeController.resetPassword(
                          phone: changePasswordWelcomeController.controller.phoneCtrl.text,
                          password: changePasswordWelcomeController.passwordNewCtrl.text.trim(),
                          confirmPassword: changePasswordWelcomeController.passwordConfirmCtrl.text.trim(),
                        );
                      },
                      size: Size(double.infinity, h * 0.065),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppThemes.primaryNavy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
