import 'package:biadgo/logic/controller/change_password_welcome_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_dimensions.dart';
import '../../widgets/button.dart';

class ChangePasswordWelcomeScreen extends StatelessWidget {
  ChangePasswordWelcomeScreen({super.key});
  final ChangePasswordWelcomeController changePasswordWelcomeController =
      Get.put(ChangePasswordWelcomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Form(
            key: changePasswordWelcomeController.confirmpassworddfromKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(children: [
              Image.asset(
                'assets/images/mahtta22.png',
                height: AppDimensions.screenHeight * 0.22,
                width: AppDimensions.screenWidth * 0.6,
              ),
              Text(
                'تغيير كلمة المرور',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Get.theme.primaryColor,
                ),
              ),
              const SizedBox(
                height: AppDimensions.paddingSmall,
              ),
              //
              const SizedBox(
                height: AppDimensions.paddingSmall,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    right: AppDimensions.paddingSmall,
                    left: AppDimensions.paddingSmall),
                child: TextFormField(
                  textAlign: TextAlign.right,
                  controller: changePasswordWelcomeController.passwordNewCtrl,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "الرجاء إدخال كلمة المرور ";
                    }
                    if (value.length < 6) {
                      return "الرجاء إدخال كلمة مرور تحتوي على أكثر من 6 عناصر ";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: ' كلمة المرور الجديدة',
                    hintStyle: const TextStyle(
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Get.theme.primaryColor,
                        width: 1,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingSmall,
                      horizontal: AppDimensions.paddingMedium,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: AppDimensions.paddingSmall,
              ),
              //
              Padding(
                padding: const EdgeInsets.only(
                    right: AppDimensions.paddingSmall,
                    left: AppDimensions.paddingSmall),
                child: TextFormField(
                  textAlign: TextAlign.right,
                  controller:
                      changePasswordWelcomeController.passwordConfirmCtrl,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "الرجاء إدخال تأكيد كلمة المرور ";
                    }
                    if (value.length < 6) {
                      return "الرجاء إدخال كلمة مرور تحتوي على أكثر من 6 عناصر ";
                    }
                    if (value !=
                        changePasswordWelcomeController.passwordNewCtrl.text) {
                      return "كلمة المرور غير متطابقة";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: ' تأكيد كلمة المرور الجديدة',
                    hintStyle: const TextStyle(
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Get.theme.primaryColor,
                        width: 1,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingSmall,
                      horizontal: AppDimensions.paddingMedium,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: AppDimensions.paddingSmall,
              ),

              Button(
                name: 'تأكيد',
                onPressed: () {
                  changePasswordWelcomeController.resetPassword(
                      phone: changePasswordWelcomeController
                          .controller.phoneCtrl.text,
                      password: changePasswordWelcomeController
                          .passwordNewCtrl.text
                          .trim(),
                      confirmPassword: changePasswordWelcomeController
                          .passwordConfirmCtrl.text
                          .trim());
                },
                size: Size(AppDimensions.screenWidth * 0.8,
                    AppDimensions.buttonHeight),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
