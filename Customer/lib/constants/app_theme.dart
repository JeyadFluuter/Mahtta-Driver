import 'package:flutter/material.dart';

class AppThemes {
  // الألوان الأساسية للهوية
  static const Color primaryOrange = Color(0xFFF48824);
  static const Color primaryNavy = Color(0xFF172736);
  // لون نقطة البداية (A) في الخريطة — برتقالي (هوية التطبيق)
  static const Color pinAColor = Color(0xFFF48824); // primaryOrange
  static const double pinAHue = 30.0; // BitmapDescriptor.hueOrange
  
  // لون نقطة النهاية (B) في الخريطة — أخضر
  static const Color pinBColor = Color(0xFF2E7D32); // Green
  static const double pinBHue = 120.0; // BitmapDescriptor.hueGreen

  static final light = ThemeData(
    useMaterial3: false,
    fontFamily: 'Almarai',
    brightness: Brightness.light,

    // اللون البرتقالي الأساسي للهوية (F48824)
    primaryColor: primaryOrange,

    // خلفية التطبيق (رمادي فاتح جداً لراحة العين وكسر حدة البياض)
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),

    // خلفية البطاقات (أبيض صافي لتبدو بارزة فوق الخلفية الرمادية)
    cardColor: Colors.white,

    hintColor: const Color(0xFF9E9E9E),

    appBarTheme: const AppBarTheme(
      // شريط التطبيق بالكحلي الفخم الخاص بالهوية (172736)
      backgroundColor: primaryNavy,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),

    colorScheme: const ColorScheme.light(
      primary: primaryOrange,  // البرتقالي (للأزرار والروابط)
      secondary: primaryNavy, // الكحلي (للعناصر التفاعلية الثانوية)
      tertiary: Color(0xFF424242),  // رمادي غامق (لأيقونات أو عناصر أقل حدة)
      error: Color(0xFFD32F2F),   // أحمر متناسق مع البرتقالي
      surface: Colors.white,
    ),

    textTheme: const TextTheme(
      // العناوين والنصوص المهمة باللون الكحلي
      bodyLarge: TextStyle(
        color: primaryNavy,
        fontWeight: FontWeight.bold,
      ),
      // النصوص العادية بالرمادي الغامق لسهولة القراءة
      bodyMedium: TextStyle(
        color: Color(0xFF424242),
      ),
      // نصوص أقل أهمية
      bodySmall: TextStyle(
        color: Color(0xFF757575),
      ),
    ),

    // تنسيق الأزرار بشكل موحد
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
