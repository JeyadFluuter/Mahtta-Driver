import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_dimensions.dart';
import '../../widgets/button.dart';
import 'login_screen.dart';

class ConfirmPasswordScreen extends StatelessWidget {
  const ConfirmPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(children: [
          Image.asset(
            'assets/images/mahtta22.png',
            height: AppDimensions.screenHeight * 0.22,
            width: AppDimensions.screenWidth * 0.6,
          ),
          const Text(
            'تغيير كلمة المرور',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(
            height: AppDimensions.paddingSmall,
          ),
          //
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            child: TextFormField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'كلمة المرور ',
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
          //
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            child: TextFormField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'تأكيد كلمة المرور',
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
              Get.offAll(() => LoginScreen());
            },
            size: Size(
                AppDimensions.screenWidth * 0.8, AppDimensions.buttonHeight),
          ),
        ]),
      ),
    );
  }
}
