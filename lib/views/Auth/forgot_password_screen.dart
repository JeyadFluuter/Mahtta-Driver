import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:piaggio_driver/logic/controller/forgot_password_controller.dart';
import '../../constants/app_dimensions.dart';
import '../../logic/controller/auth_controller.dart';
import '../../widgets/button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});
  final ForgotPasswordController controller =
      Get.put(ForgotPasswordController());
  final AuthController controllerr = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.light.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppThemes.light.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left_rounded, color: AppThemes.primaryNavy, size: 30),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
            child: Form(
              key: controller.changephonefromKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/Asset 3.png',
                    height: AppDimensions.screenHeight * 0.18,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'نسيت كلمة السر؟',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'أدخل رقم هاتفك وسنرسل لك رمز تحقق لمساعدتك على إعادة تعيين كلمة المرور',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppThemes.primaryNavy.withOpacity(0.6),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'رقم الهاتف',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppThemes.primaryNavy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: controller.phoneCtrl,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 16, letterSpacing: 1.2),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "الرجاء إدخال رقم الهاتف";
                      }
                      if (value.length < 9) {
                        return "رقم الهاتف يجب أن يكون 9 أرقام على الأقل";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: '09X XXXXXXX',
                      hintStyle: TextStyle(
                        color: AppThemes.primaryNavy.withOpacity(0.4),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(Icons.phone_android, color: AppThemes.primaryNavy),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppThemes.primaryNavy.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppThemes.primaryOrange, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppThemes.light.colorScheme.error, width: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Obx(() {
                    if (controller.errorMessage.isEmpty) return const SizedBox.shrink();
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppThemes.light.colorScheme.error.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppThemes.light.colorScheme.error.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: AppThemes.light.colorScheme.error, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              controller.errorMessage.value,
                              style: TextStyle(
                                  color: AppThemes.light.colorScheme.error,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  Obx(
                    () => Button(
                      isLoading: controller.isLoading.value,
                      name: 'إرسال الرمز',
                      onPressed: () {
                        controller.forgotPassword(
                          phone: controller.phoneCtrl.text.trim(),
                        );
                      },
                      size: const Size(double.infinity, AppDimensions.buttonHeight),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
