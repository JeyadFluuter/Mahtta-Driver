import 'package:piaggio_driver/constants/app_theme.dart';
// ignore: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequiredDocumentsScreen extends StatelessWidget {
  const RequiredDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              "الأوراق المطلوبة",
              style: TextStyle(
                  color: AppThemes.primaryNavy,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left_rounded, color: AppThemes.primaryNavy, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/documents.png',
                  height: 150,
                ),
                const SizedBox(height: 20),
                const Text(
                  "لإكمال التسجيل، يُرجى إحضار الأوراق التالية:",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    buildRequirementItem(
                        Icons.credit_card, "نسخة من رخصة القيادة"),
                    buildRequirementItem(
                        Icons.assignment, "صورة من جواز السفر أو الهوية"),
                    buildRequirementItem(
                        Icons.file_copy, "شهادة خبرة (إن وجدت)"),
                    buildRequirementItem(Icons.photo, "صورة شخصية حديثة"),
                    buildRequirementItem(
                        Icons.receipt_long, "إيصال دفع رسوم التسجيل"),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: const Text(
                    "العودة",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemes.primaryNavy,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 40),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget buildRequirementItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppThemes.primaryNavy, size: 28),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
