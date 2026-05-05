import 'package:biadgo/routes/routes.dart';
import 'package:biadgo/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_dimensions.dart';
import 'package:biadgo/constants/app_theme.dart';

class FinishSignup extends StatelessWidget {
  const FinishSignup({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.blue.shade50.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Logo Section with subtle shadow
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/mahtta22.png',
                    height: AppDimensions.screenHeight * 0.22,
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(flex: 1),
                // Text Content
                const Text(
                  'أنت جاهز للإنطلاق',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppThemes.primaryNavy,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'تهانينا! تم إنشاء حسابك بنجاح.\nيمكنك الآن البدء في طلب خدماتنا بكل سهولة.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(flex: 3),
                // Action Button
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8C00).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.loginscreen),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8C00), // Orange color from screenshot
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
