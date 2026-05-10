import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:piaggio_driver/logic/controller/forgot_password_controller.dart';
import 'package:piaggio_driver/logic/controller/otp_verify_forgot_password_controller.dart';
import 'package:pinput/pinput.dart';
import '../../constants/app_dimensions.dart';
import '../../widgets/button.dart';

class OtpForgotPasswordScreen extends StatelessWidget {
  OtpForgotPasswordScreen({super.key});
  final OtpVerifyForgotPasswordController controller =
      Get.put(OtpVerifyForgotPasswordController());

  final ForgotPasswordController controllerr =
      Get.put(ForgotPasswordController());

  final defaultPinTheme = PinTheme(
    width: 60,
    height: 60,
    textStyle: const TextStyle(
      fontSize: 20,
      color: AppThemes.primaryNavy,
    ),
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppThemes.primaryNavy),
    ),
  );

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
            child: Form(
              key: controller.verfiyykey,
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
                    'تفعيل الحساب',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'الرجاء إدخال رمز التحقق المكون من 6 أرقام والذي تم إرساله إلى هاتفك',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppThemes.primaryNavy.withOpacity(0.6),
                      height: 1.5,
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
                          border: Border.all(color: AppThemes.primaryNavy, width: 2),
                        ),
                      ),
                      errorPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          border: Border.all(color: Colors.red),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "الرجاء إدخال رمز التحقق";
                        }
                        if (value.length < 6) {
                          return "الرمز يجب أن يكون 6 أرقام";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  Obx(
                    () => Column(
                      children: [
                        if (!controller.isTimerFinished.value)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                controller.timerText,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppThemes.primaryNavy,
                                ),
                              ),
                              Text(
                                " إعادة الإرسال خلال ",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppThemes.primaryNavy.withOpacity(0.6),
                                ),
                              ),
                            ],
                          )
                        else
                          TextButton(
                            onPressed: () => controller.resendOtp(),
                            child: Text(
                              "إعادة إرسال الرمز",
                              style: TextStyle(
                                color: AppThemes.primaryOrange,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  Obx(() => controller.errorMessage.value.isNotEmpty
                      ? Container(
                          margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppThemes.light.colorScheme.error.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppThemes.light.colorScheme.error.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: AppThemes.light.colorScheme.error, size: 24),
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
                        )
                      : const SizedBox.shrink()),

                  Obx(() => controllerr.successMessage.value.isNotEmpty
                      ? Container(
                          margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
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
                                  controllerr.successMessage.value,
                                  style: TextStyle(
                                      color: Colors.green.shade900,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink()),

                  const SizedBox(height: 10),
                  Obx(() => Button(
                        name: 'تأكيد الرمز',
                        isLoading: controller.isLoading.value,
                        onPressed: () {
                          controller.otpVerifyforgotpassword();
                        },
                        size: const Size(double.infinity, AppDimensions.buttonHeight),
                      )),
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
