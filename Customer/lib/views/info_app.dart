// lib/views/info_app_screen.dart

import 'package:biadgo/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:biadgo/constants/app_theme.dart';

class InfoApp extends StatelessWidget {
  const InfoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: AppThemes.primaryNavy),
          ),
          title: const Text(
            'عن التطبيق',
            style: TextStyle(color: AppThemes.primaryNavy, fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo / illustration
                Container(
                  decoration: const BoxDecoration(
                      // shape: BoxShape.circle,
                      ),
                  child: Image.asset(
                    'assets/images/mahtta22.png',
                    width: AppDimensions.screenWidth * 0.4,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info,
                      color: Get.theme.primaryColor,
                      size: 25,
                    ),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    const Text(
                      'نبذة عن تطبيق محطة (للمستخدمين)',
                      style: TextStyle(
                        color: AppThemes.primaryNavy,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                // Description
                Text(
                  ' محطة هو تطبيق ذكي يقدّم حلاً متكاملاً لتسهيل عمليات نقل البضائع داخل ليبيا، ويُلبي احتياجات الأفراد والشركات بكفاءة.نهدف إلى تحسين تجربة النقل من خلال نظام سلس، آمن، وسهل الاستخدام  من حجز المركبة إلى تتبع الرحلة حتى التسليم.',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppThemes.primaryNavy,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingLarge),

                _buildFeatureItem(
                    Icons.local_shipping, 'شاحنات متنوعة الأحجام'),
                const SizedBox(height: AppDimensions.paddingSmall),
                _buildFeatureItem(Icons.security, 'تتبع وصول الشحنات بأمان'),
                const SizedBox(height: AppDimensions.paddingSmall),
                _buildFeatureItem(Icons.schedule, 'حجز وتتبع الطلب بسهولة'),
                const SizedBox(height: AppDimensions.paddingSmall),
                _buildFeatureItem(
                    Icons.support_agent, 'دعم فني على مدار الساعة'),
                const SizedBox(height: AppDimensions.paddingLarge),

                // Version tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLarge,
                    vertical: AppDimensions.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Get.theme.primaryColor.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'V 1.0.0',
                    style: TextStyle(
                      color: Get.theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Get.theme.primaryColor.withValues(alpha: .2),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(AppDimensions.paddingSmall * 1.2),
          child: Icon(icon, color: Get.theme.primaryColor, size: 18),
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: AppThemes.primaryNavy),
          ),
        ),
      ],
    );
  }
}
