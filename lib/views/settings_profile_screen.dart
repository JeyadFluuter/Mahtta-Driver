import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/logic/controller/me_controller.dart';
import 'package:piaggio_driver/views/Auth/change_password_screen.dart';
import '../logic/controller/logout_controller.dart';

class SettingsProfileScreen extends StatelessWidget {
  final LogOutController logOutController = Get.put(LogOutController());
  final MeController meController = Get.find<MeController>();

  SettingsProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ═══════════════════════════════
                // UNIFIED HERO HEADER
                // ═══════════════════════════════
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppThemes.primaryOrange, Color(0xFFE67E22)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Top Row: Back Button + Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                          ),
                          const Text(
                            "إعدادات الحساب",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 48), // balance
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Avatar
                      Obx(() {
                        final url = meController.driverImage.value;
                        return Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [AppThemes.primaryOrange, Color(0xFFFFB347)],
                            ),
                          ),
                          child: ClipOval(
                            child: url.isNotEmpty
                                ? Image.network(
                                    url,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 90,
                                      height: 90,
                                      color: Colors.white,
                                      child: Icon(Icons.person, size: 55, color: AppThemes.primaryNavy),
                                    ),
                                  )
                                : Container(
                                    width: 90,
                                    height: 90,
                                    color: Colors.white,
                                    child: Icon(Icons.person, size: 55, color: AppThemes.primaryNavy),
                                  ),
                          ),
                        );
                      }),
                      const SizedBox(height: 14),
                      // Name
                      Obx(() => Text(
                            "${meController.firstname.value} ${meController.lastname.value}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      const SizedBox(height: 5),
                      // Phone
                      Obx(() => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.phone_rounded, size: 13, color: Colors.white.withOpacity(0.55)),
                              const SizedBox(width: 5),
                              Text(
                                meController.phone.value,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )),
                      const SizedBox(height: 18),
                      // Status & Rating Bar — Real Data
                      Obx(() {
                        final isActive = meController.isActive.value == '1';
                        final rating = meController.averageRating.value;
                        final count = meController.ratingsCount.value;
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStat(
                                "الحالة",
                                isActive ? "نشط" : "غير نشط",
                                Icons.circle,
                                isActive ? Colors.greenAccent : AppThemes.primaryNavy,
                              ),
                              Container(height: 22, width: 0.8, color: Colors.white.withOpacity(0.2)),
                              _buildStat(
                                "التقييم",
                                rating > 0 ? rating.toStringAsFixed(1) : "--",
                                Icons.star_rounded,
                                Colors.amber,
                              ),
                              Container(height: 22, width: 0.8, color: Colors.white.withOpacity(0.2)),
                              _buildStat(
                                "التقييمات",
                                count.toString(),
                                Icons.reviews_rounded,
                                Colors.lightBlueAccent,
                              ),
                            ],
                          ),
                        );
                      }),

                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Settings Options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        "تغيير كلمة المرور",
                        Icons.lock_outline,
                        AppThemes.primaryNavy,
                        () => Get.to(() => ChangePasswordScreen()),
                      ),
                      const SizedBox(height: 16),
                      _buildSettingsTile(
                        "حذف الحساب",
                        Icons.delete_outline,
                        Colors.red,
                        () => _showDeleteAccountDialog(context),
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }


  Widget _buildSettingsTile(
      String title, IconData icon, Color color, VoidCallback onTap,
      {bool isDestructive = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Icon(
          icon,
          color: color,
          size: 28,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          size: 22,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    final RxBool isObscure = true.obs;
    final RxString errorMessage = "".obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon in Circle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFFB057),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              // Title
              const Text(
                "حذف الحساب نهائياً",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              // Subtitle
              Text(
                "نأسف لرؤيتك ترحل! هل أنت متأكد من رغبتك في حذف حسابك؟ سيؤدي هذا الإجراء إلى فقدان كافة بياناتك وطلباتك المخزنة.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              // Password Input
              Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: errorMessage.value.isNotEmpty
                                ? Colors.red.shade300
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: TextField(
                          controller: passwordController,
                          obscureText: isObscure.value,
                          textAlign: TextAlign.right,
                          onChanged: (_) => errorMessage.value = "",
                          decoration: InputDecoration(
                            hintText: "أدخل كلمة المرور للتأكيد",
                            hintStyle: TextStyle(
                                color: Colors.grey.shade400, fontSize: 13),
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Colors.grey, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isObscure.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: Colors.grey,
                              ),
                              onPressed: () => isObscure.toggle(),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      if (errorMessage.value.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, right: 8),
                          child: Text(
                            errorMessage.value,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  )),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Obx(() => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppThemes.primaryNavy,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          onPressed: logOutController.isLoading.value
                              ? null
                              : () async {
                                  if (passwordController.text.isEmpty) {
                                    errorMessage.value = "الرجاء إدخال كلمة المرور";
                                    return;
                                  }
                                  final result = await logOutController
                                      .deleteAccount(passwordController.text);
                                  if (result != null) {
                                    errorMessage.value = result;
                                  }
                                },
                          child: logOutController.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  "حذف الحساب",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                        )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "تراجع",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

