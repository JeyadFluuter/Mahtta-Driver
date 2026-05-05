import 'package:biadgo/logic/controller/forgot_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_dimensions.dart';
import '../../logic/controller/auth_controller.dart';
import '../../widgets/button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});
  final ForgotPasswordController controller =
      Get.put(ForgotPasswordController(), permanent: true);

  final AuthController controllerr = Get.put(AuthController());

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
              key: controller.changephonefromKey,
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
                    'نسيت كلمة السر؟',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'أدخل رقم هاتفك وسنرسل لك رمز تحقق لمساعدتك على إعادة تعيين كلمة المرور',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
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
                        color: Get.theme.primaryColor,
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
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(Icons.phone_android, color: Get.theme.primaryColor),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Get.theme.primaryColor, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Obx(() {
                    if (controller.errorMessage.isEmpty) return const SizedBox.shrink();
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Text(
                        controller.errorMessage.value,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                        textAlign: TextAlign.center,
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
