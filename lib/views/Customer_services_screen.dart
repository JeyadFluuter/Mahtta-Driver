// lib/views/Customer_services_screen.dart
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:piaggio_driver/constants/app_theme.dart';

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

  void _showContactOptions(BuildContext context, String number) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.phone, color: Colors.white),
                ),
                title: const Text('اتصال هاتفي',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppThemes.primaryNavy)),
                onTap: () {
                  Navigator.pop(context);
                  _callPhone(number);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.chat, color: Colors.white),
                ),
                title: const Text('مراسلة عبر واتساب',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppThemes.primaryNavy)),
                onTap: () {
                  Navigator.pop(context);
                  _openWhatsApp(number);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
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
                style: TextStyle(fontSize: 16, height: 1.5, color: AppThemes.primaryNavy),
              ),
              const SizedBox(height: AppDimensions.paddingLarge * 1.2),

              // الدعم الفني 1
              _ContactCard(
                icon: Icons.support_agent,
                title: 'الدعم الفني',
                contactInfo: '091 705 7 333',
                color: Colors.green,
                onTap: () => _showContactOptions(context, '0917057333'),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),

              // الدعم الفني 2
              _ContactCard(
                icon: Icons.support_agent,
                title: 'الدعم الفني',
                contactInfo: '091 705 8 333',
                color: Colors.green,
                onTap: () => _showContactOptions(context, '0917058333'),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),

              // الدعم الفني 3
              _ContactCard(
                icon: Icons.support_agent,
                title: 'الدعم الفني',
                contactInfo: '091 705 9 333',
                color: Colors.green,
                onTap: () => _showContactOptions(context, '0917059333'),
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
              backgroundColor: color.withOpacity(.1),
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
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      letterSpacing: 1.2,
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
