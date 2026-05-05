import 'package:biadgo/logic/controller/auth_controller.dart';
import 'package:biadgo/logic/controller/forgot_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../constants/app_dimensions.dart';
import '../../../logic/controller/otp_verify_signUp_controller.dart';
import '../../../widgets/button.dart';
import 'package:biadgo/constants/app_theme.dart';

class OtpScreenSignup extends StatelessWidget {
  OtpScreenSignup({super.key});

  final AuthController controllerrr = Get.put(AuthController());
  final ForgotPasswordController controllerr = Get.put(ForgotPasswordController());
  final OtpVerifySignupController controller = Get.put(OtpVerifySignupController());

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 55,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppThemes.primaryNavy,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'تفعيل الحساب',
          style: TextStyle(color: AppThemes.primaryNavy, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_forward_ios, color: AppThemes.primaryNavy, size: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
            child: Form(
              key: controller.verfiykey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Image.asset(
                    'assets/images/mahtta22.png',
                    height: AppDimensions.screenHeight * 0.25,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'أدخل رمز التحقق',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'لقد أرسلنا رمزاً مكوناً من 6 أرقام إلى هاتفك\n${controllerrr.phoneCtrl.text}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Pinput(
                      controller: controller.codecontroller,
                      length: 6,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          color: Colors.white,
                          border: Border.all(color: Get.theme.primaryColor, width: 2),
                        ),
                      ),
                      errorPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red, width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "الرجاء إدخال الرمز";
                        }
                        if (value.length < 6) {
                          return "يجب إدخال 6 أرقام";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(() => Column(
                        children: [
                          if (controller.errorMessage.value.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: Colors.red, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      controller.errorMessage.value,
                                      style: TextStyle(
                                          color: Colors.red.shade900,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (controller.successMessage.value.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline,
                                      color: Colors.green, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      controller.successMessage.value,
                                      style: TextStyle(
                                          color: Colors.green.shade900,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      )),
                  const SizedBox(height: 35),
                  Obx(
                    () => Column(
                      children: [
                        if (!controller.isTimerFinished.value)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Get.theme.primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.timer_outlined, color: Get.theme.primaryColor, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  "إعادة الإرسال خلال ",
                                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                ),
                                Text(
                                  controller.timerText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Get.theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          TextButton.icon(
                            onPressed: () => controller.resendOtp(),
                            icon: Icon(Icons.refresh, color: Get.theme.primaryColor, size: 18),
                            label: Text(
                              "إعادة إرسال الرمز",
                              style: TextStyle(
                                color: Get.theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 45),
                  Obx(() => Button(
                        name: 'تأكيد الرمز',
                        isLoading: controller.isLoading.value,
                        onPressed: () {
                          controller.otpVerifySignupController();
                        },
                        size: const Size(double.infinity, AppDimensions.buttonHeight),
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
}
