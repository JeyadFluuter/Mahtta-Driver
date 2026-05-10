import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:piaggio_driver/views/Auth/login_screen.dart';
import 'package:piaggio_driver/widgets/button.dart';
import '../../../../constants/app_dimensions.dart';

class FinishSignup extends StatelessWidget {
  const FinishSignup({super.key});
  @override
  Widget build(BuildContext context) {
    final h = AppDimensions.screenHeight;
    final w = AppDimensions.screenWidth;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.07),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset(
                'assets/images/Asset 3.png',
                height: h * 0.22,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),
              Text(
                'أنت جاهز للإنطلاق',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.primaryNavy,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'تم إنشاء حسابك بنجاح. يمكنك الآن تسجيل الدخول والبدء في استقبال الطلبات.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: h * 0.065,
                child: Button(
                  name: "تسجيل الدخول",
                  onPressed: () {
                    Get.offAll(() => LoginScreen());
                  },
                  size: Size(double.infinity, h * 0.065),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
