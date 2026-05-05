import 'package:piaggio_driver/views/Auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/widgets/button.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/widgets/step.dart';
import 'package:piaggio_driver/views/terms_policies_screen.dart';
import 'package:piaggio_driver/constants/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = AppDimensions.screenHeight;
    final w = AppDimensions.screenWidth;

    return Scaffold(
      backgroundColor: AppThemes.light.scaffoldBackgroundColor,
      body: SafeArea(
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
                'مرحباً بك في محطة',
                style: TextStyle(
                  fontSize: w * 0.063,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.primaryNavy,
                ),
              ),
              SizedBox(height: h * 0.01),
              Text(
                'خدمة نقل البضائع الأسرع والأوفر',
                style: TextStyle(
                  fontSize: w * 0.038,
                  color: AppThemes.primaryNavy.withOpacity(0.6),
                ),
              ),

              SizedBox(height: h * 0.06),

              // ـــ Divider ـــ
              Row(
                children: [
                  Expanded(child: Divider(color: AppThemes.primaryNavy.withOpacity(0.1))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: w * 0.03),
                    child: Text(
                      'ابدأ الآن',
                      style: TextStyle(
                        fontSize: w * 0.033,
                        color: AppThemes.primaryNavy.withOpacity(0.4),
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppThemes.primaryNavy.withOpacity(0.1))),
                ],
              ),

              SizedBox(height: h * 0.03),

              // ـــ Login Button ـــ
              SizedBox(
                width: double.infinity,
                height: h * 0.065,
                child: Button(
                  name: 'تسجيل الدخول',
                  onPressed: () => Get.to(() => LoginScreen()),
                  size: Size(double.infinity, h * 0.065),
                ),
              ),
              SizedBox(height: h * 0.02),

              // ـــ Register Button ـــ
              SizedBox(
                width: double.infinity,
                height: h * 0.065,
                child: Button(
                  name: 'إنشاء حساب',
                  onPressed: () => Get.to(() => const RegistrationStepper()),
                  size: Size(double.infinity, h * 0.065),
                ),
              ),

              const Spacer(),

              // ـــ Terms ـــ
              InkWell(
                onTap: () => Get.to(() => const TermsPoliciesScreen()),
                child: Text(
                  'الشروط والسياسات',
                  style: TextStyle(
                    fontSize: w * 0.034,
                    fontWeight: FontWeight.w500,
                    color: AppThemes.primaryNavy.withOpacity(0.6),
                    decoration: TextDecoration.underline,
                    decorationColor: AppThemes.primaryNavy.withOpacity(0.3),
                  ),
                ),
              ),
              SizedBox(height: h * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
