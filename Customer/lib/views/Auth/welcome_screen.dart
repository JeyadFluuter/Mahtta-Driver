import 'package:biadgo/views/Auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:biadgo/constants/app_dimensions.dart';
import '../../widgets/button.dart';
import 'package:get/get.dart';
import 'User_SignUp/step.dart';
import '../termes_policies.dart';
import 'package:biadgo/constants/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
            children: [
              SizedBox(height: h * 0.06),

              // ـــ Logo ـــ
              Image.asset(
                'assets/images/mahtta22.png',
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
                  color: Colors.grey.shade600,
                ),
              ),

              SizedBox(height: h * 0.06),

              // ـــ Divider ـــ
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade200)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: w * 0.03),
                    child: Text(
                      'ابدأ الآن',
                      style: TextStyle(
                        fontSize: w * 0.033,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade200)),
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
                onTap: () => Get.to(() => const TermesPolicies()),
                child: Text(
                  'الشروط والسياسات',
                  style: TextStyle(
                    fontSize: w * 0.034,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.grey.shade400,
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
