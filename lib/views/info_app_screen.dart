import 'package:piaggio_driver/constants/app_theme.dart';
// lib/views/info_app_screen.dart
import 'package:flutter/material.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:get/get.dart';

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
          title: const Text(
            'عن التطبيق',
            style: TextStyle(color: AppThemes.primaryNavy, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: AppThemes.primaryNavy, size: 30),
            onPressed: () => Navigator.pop(context),
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
                    'assets/images/piaggio.jpg',
                    width: AppDimensions.screenWidth * 0.5,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
                // Title
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info,
                      color: AppThemes.primaryOrange,
                      size: 25,
                    ),
                     SizedBox(width: AppDimensions.paddingSmall),
                     Text(
                      'نبذة عن تطبيق بيادجو (للمستخدمين)',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                // Description
                Text(
                  ' انضم إلى أسطول بيادجو وابدأ في تنفيذ الطلبات بسهولة عبر تطبيق احترافي يربطك مباشرة بالعملاء.نقدّم لك منصة تتيح لك الاستفادة من وقتك ومركبتك، عبر نظام سلس وآمن يسهّل إدارة رحلاتك وزيادة دخلك اليومي.',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.grey.shade600,
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
                    color: AppThemes.primaryNavy.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'V 0.1.3',
                    style: TextStyle(
                      color: AppThemes.primaryNavy,
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
            color: AppThemes.primaryOrange.withValues(alpha: .2),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(AppDimensions.paddingSmall * 1.2),
          child: Icon(icon, color: AppThemes.primaryNavy, size: 18),
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
