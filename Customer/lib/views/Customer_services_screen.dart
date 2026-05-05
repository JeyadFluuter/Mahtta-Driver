// lib/views/customer_services_screen.dart
import 'package:biadgo/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:biadgo/constants/app_theme.dart';

class CustomerServicesScreen extends StatelessWidget {
  const CustomerServicesScreen({super.key});

  Future<void> _callPhone(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    await launchUrl(uri);
  }

  Future<void> _openWhatsApp(String number) async {
    final uri = Uri.parse('https://wa.me/$number');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openEmail(String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
    );
    await launchUrl(uri);
  }

  Future<void> _openWeb(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
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
            "خدمة العملاء",
            style: TextStyle(color: AppThemes.primaryNavy, fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
              vertical: AppDimensions.paddingLarge * 1.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'نحن هنا لمساعدتك على مدار الساعة لا تتردد في التواصل معنا عبر الأرقام التالية أو عبر البريد الإلكتروني.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, height: 1.5, color: AppThemes.primaryNavy),
              ),
              const SizedBox(height: AppDimensions.paddingLarge * 1.2),

              // الاتصال
              _ContactCard(
                icon: Icons.phone,
                title: 'اتصل بنا',
                contactInfo: '0918887666',
                color: Colors.green,
                onTap: () => _callPhone('0918887666'),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),

              // واتساب
              _ContactCard(
                icon: Icons.phone,
                title: 'واتساب',
                contactInfo: '0918887666',
                color: Colors.teal,
                onTap: () => _openWhatsApp('0918887666'),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),

              // البريد
              _ContactCard(
                icon: Icons.email,
                title: 'البريد الإلكتروني',
                contactInfo: 'help@mahtta.ly',
                color: Colors.blue,
                onTap: () => _openEmail('help@mahtta.ly'),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),

              // فيسبوك
              _ContactCard(
                icon: Icons.facebook,
                title: 'Facebook',
                contactInfo: 'facebook.com/mahtta.ly',
                color: Colors.blue,
                onTap: () => _openWeb('https://www.facebook.com/mahtta.ly'),
              ),

              const Spacer(),
              Center(
                child: Text(
                  '© 2026 Mahtta  جميع الحقوق محفوظة',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String contactInfo;
  final Color color;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.contactInfo,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: .1),
              radius: 22,
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingSmallX),
                  Text(
                    contactInfo,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
