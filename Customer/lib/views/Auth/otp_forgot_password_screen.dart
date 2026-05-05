import 'package:biadgo/logic/controller/auth_controller.dart';
import 'package:biadgo/logic/controller/forgot_password_controller.dart';
import 'package:biadgo/logic/controller/otp_verify_forgot_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../constants/app_dimensions.dart';
import '../../widgets/button.dart';

class OtpForgotPasswordScreen extends StatelessWidget {
  OtpForgotPasswordScreen({super.key});
  final OtpVerifyForgotPasswordController controller =
      Get.put(OtpVerifyForgotPasswordController());

  final ForgotPasswordController forgotCtrl =
      Get.find<ForgotPasswordController>();

  final AuthController controllerrr = Get.put(AuthController());

  final defaultPinTheme = PinTheme(
    width: 60,
    height: 60,
    textStyle: const TextStyle(
      fontSize: 20,
      color: Colors.black,
    ),
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Get.theme.primaryColor),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
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
                    'assets/images/mahtta22.png',
                    height: AppDimensions.screenHeight * 0.18,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'تفعيل الحساب',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'الرجاء إدخال رمز التحقق المكون من 6 أرقام والذي تم إرساله إلى هاتفك',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
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
                          border: Border.all(color: Get.theme.primaryColor, width: 2),
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
                                  color: Get.theme.primaryColor,
                                ),
                              ),
                              Text(
                                " إعادة الإرسال خلال ",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
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
                                color: Get.theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Button(
                    name: 'تأكيد الرمز',
                    onPressed: () {
                      controller.otpVerifyforgotpassword();
                    },
                    size: const Size(double.infinity, AppDimensions.buttonHeight),
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
