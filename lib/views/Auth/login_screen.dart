import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:piaggio_driver/logic/controller/auth_controller.dart';
import 'package:piaggio_driver/views/Auth/forgot_password_screen.dart';
import 'package:piaggio_driver/widgets/button.dart';
import 'package:piaggio_driver/widgets/step.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    final h = AppDimensions.screenHeight;
    final w = AppDimensions.screenWidth;

    return Scaffold(
      backgroundColor: AppThemes.light.scaffoldBackgroundColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(color: AppThemes.primaryOrange),
            );
          }
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.07),
              child: Column(
                children: [
                  SizedBox(height: h * 0.06),

                  // ـــ Logo ـــ
                  Image.asset(
                    'assets/images/piaggio22.png',
                    height: h * 0.22,
                    fit: BoxFit.contain,
                  ),

                  SizedBox(height: h * 0.04),

                  // ـــ Title ـــ
                  Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontSize: w * 0.063,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.primaryNavy,
                    ),
                  ),
                  SizedBox(height: h * 0.01),
                  Text(
                    'أدخل بياناتك للمتابعة',
                    style: TextStyle(
                      fontSize: w * 0.038,
                      color: AppThemes.primaryNavy.withOpacity(0.6),
                    ),
                  ),

                  SizedBox(height: h * 0.04),

                  // ـــ Error ـــ
                  Obx(() => controller.errorMessage.value.isNotEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFFCDD2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  controller.errorMessage.value,
                                  style: const TextStyle(
                                      color: Color(0xFFC62828),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink()),

                  // ـــ Form ـــ
                  Form(
                    key: controller.loginfromKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: controller.phoneCtrl,
                          hint: 'رقم الهاتف',
                          icon: Icons.phone_android_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) return "الرجاء إدخال رقم الهاتف";
                            if (!controller.phoneNumberPattern.hasMatch(value)) return "رقم هاتف غير صحيح";
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        Obx(() => _buildTextField(
                              controller: controller.passwordCtrl,
                              hint: 'كلمة المرور',
                              icon: Icons.lock_outline,
                              obscureText: controller.isPasswordHidden.value,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isPasswordHidden.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return "الرجاء إدخال كلمة المرور";
                                if (value.length < 6) return "كلمة المرور قصيرة جداً";
                                return null;
                              },
                            )),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Get.to(() => ForgotPasswordScreen()),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'نسيت كلمة المرور؟',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: w * 0.033,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // ـــ Login Button ـــ
                        SizedBox(
                          width: double.infinity,
                          height: h * 0.065,
                          child: Button(
                            name: 'تسجيل الدخول',
                            onPressed: () {
                              controller.loginUser(
                                phone: controller.phoneCtrl.text.trim(),
                                password: controller.passwordCtrl.text.trim(),
                              );
                            },
                            size: Size(double.infinity, h * 0.065),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // ـــ Sign Up Link ـــ
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ليس لديك حساب؟',
                              style: TextStyle(
                                fontSize: w * 0.035,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: () => Get.to(() => const RegistrationStepper()),
                              child: Text(
                                'إنشئ الآن',
                                style: TextStyle(
                                  fontSize: w * 0.035,
                                  fontWeight: FontWeight.bold,
                                  color: AppThemes.primaryOrange,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppThemes.primaryNavy.withOpacity(0.4), size: 20),
        suffixIcon: suffixIcon,
        hintText: hint,
        hintStyle: TextStyle(color: AppThemes.primaryNavy.withOpacity(0.4), fontSize: 13),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppThemes.primaryNavy.withOpacity(0.1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppThemes.primaryOrange, width: 1.5),
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
