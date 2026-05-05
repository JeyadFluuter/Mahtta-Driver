import 'package:biadgo/constants/app_dimensions.dart';
import 'package:biadgo/views/Auth/change_password_screen.dart';
import 'package:biadgo/views/Auth/change_phone_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:biadgo/widgets/delete_account_dialog.dart';
import 'package:biadgo/constants/app_theme.dart';
import '../logic/controller/logout_controller.dart';

class SafetySecurityScreen extends StatelessWidget {
  final LogOutController logOutController = Get.put(LogOutController());

  SafetySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: AppThemes.primaryNavy),
          ),
          title: const Text(
            "إعدادات الدخول و الأمان",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppThemes.primaryNavy),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                  child: Column(
                    children: [
                      const SizedBox(height: AppDimensions.paddingSmall * 1.2),
                      _buildListTile("تغيير رقم الهاتف", Icons.phone, () {
                        Get.to(() => ChangePhoneScreen());
                      }),
                      const Divider(
                        thickness: 0.5,
                        indent: 30,
                        endIndent: 30,
                      ),
                      _buildListTile("تغيير كلمة المرور", Icons.lock, () {
                        Get.to(() => ChangePasswordScreen());
                      }),
                      const Divider(
                        thickness: 0.5,
                        indent: 30,
                        endIndent: 30,
                      ),
                      _buildListTile("حذف الحساب", Icons.delete_forever, () {
                        Get.dialog(DeleteAccountDialog());
                      }, color: Colors.red),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon, VoidCallback ontap,
      {Color? color}) {
    final Color tileColor = color ?? AppThemes.primaryNavy;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingSmall,
            vertical: AppDimensions.paddingSmall),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: ontap,
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Icon(icon, color: Get.theme.primaryColor),
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    color: tileColor,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: tileColor),
            ],
          ),
        ),
      ),
    );
  }
}
