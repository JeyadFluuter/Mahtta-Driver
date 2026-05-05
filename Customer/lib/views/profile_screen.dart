import 'package:biadgo/constants/app_dimensions.dart';
import 'package:biadgo/logic/controller/me_controller.dart';
import 'package:biadgo/logic/controller/logout_controller.dart';
import 'package:biadgo/logic/controller/profile_controller.dart';
import 'package:biadgo/views/customer_services_screen.dart';
import 'package:biadgo/views/info_app.dart';
import 'package:biadgo/views/safety_security_screen.dart';
import 'package:biadgo/views/termes_policies.dart';
import 'package:biadgo/views/save_location_screen.dart';
import 'package:biadgo/views/profile_details.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:biadgo/constants/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  final logOutController = Get.find<LogOutController>();
  final profileController = Get.find<ProfileController>();
  final meController = Get.find<MeController>();
  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "إعدادات الحساب",
          style: TextStyle(color: AppThemes.primaryNavy, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: CustomRefreshIndicator(
        onRefresh: () async {
          debugPrint("Refresh triggered");
          await meController.meUser();
          debugPrint(
              "First name after refresh: ${meController.firstname.value}");
          debugPrint("Refresh complete");
        },
        offsetToArmed: 80,
        builder: (context, child, indicator) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              if (!indicator.isIdle)
                Positioned(
                  top: 35.0 * indicator.value,
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Get.theme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: indicator.isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 20 + (5 * indicator.value).clamp(0, 5),
                            ),
                    ),
                  ),
                ),
              Transform.translate(
                offset: Offset(0, 100.0 * indicator.value),
                child: child,
              ),
            ],
          );
        },
        child: Obx(() {
          if (meController.isLoading.value) {
            return _buildSkeleton();
          }
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: AppDimensions.paddingSmall),
                child: Column(
                  children: [
                    _buildProfileSection(),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    const Divider(
                      indent: 30,
                      endIndent: 30,
                      thickness: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                      child: Column(
                        children: [
                          _buildListTile("بيانات الحساب", Icons.person, () {
                            Get.to(() => const ProfileDetails());
                          }),
                          _buildListTile("الدخول والأمان", Icons.lock, () {
                            Get.to(() => SafetySecurityScreen());
                          }),
                          _buildListTile("المواقع المحفوظة", Icons.location_on,
                              () {
                            Get.to(() => const SaveLocationScreen());
                          }),
                          const Divider(
                            thickness: 0.5,
                            indent: 30,
                            endIndent: 30,
                          ),
                          _buildListTile(" خدمة العملاء", Icons.support_agent,
                              () {
                            Get.to(const CustomerServicesScreen());
                          }),
                          // _buildListTile("تقييم التطبيق", Icons.star, () async {
                          //   final InAppReview inAppReview = InAppReview.instance;
                          //   // نفتح المتجر مباشرة لضمان الاستجابة أمام المراجع والمستخدم
                          //   inAppReview.openStoreListing(
                          //       appStoreId: '6763004674');
                          // }),
                          _buildListTile("عن التطبيق", Icons.info, () {
                            Get.to(() => const InfoApp());
                          }),
                          _buildListTile("سياسة الخصوصية", Icons.privacy_tip, () {
                            Get.to(() => const TermesPolicies());
                          }),
                          const Divider(
                            thickness: 0.5,
                            indent: 30,
                            endIndent: 30,
                          ),
                          Obx(() => _buildListTile(
                                "تسجيل الخروج",
                                Icons.logout,
                                logOutController.busy.value
                                    ? () {} // ما يدير شي لو loading
                                    : () {
                                        logOutController.logout();
                                      },
                                color: Colors.red,
                                isLoading: logOutController.busy.value,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const CircleAvatar(radius: 30, backgroundColor: Colors.white),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 15, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 80, height: 12, color: Colors.white),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(indent: 30, endIndent: 30),
            const SizedBox(height: 20),
            ...List.generate(
                6,
                (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              child: CircleAvatar(
                radius: 30,
                backgroundImage: meController.image.value.isNotEmpty
                    ? NetworkImage(meController.image.value)
                    : const AssetImage("assets/images/profile2.png")
                        as ImageProvider,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Obx(() {
              final firstName = meController.firstname.value;
              final lastName = meController.lastname.value;
              final phone = meController.phone.value;

              final hasError =
                  firstName.isEmpty || lastName.isEmpty || phone.isEmpty;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasError ? "زبوننا العزيز" : "$firstName $lastName",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingSmallX),
                  Text(
                    hasError ? "رقم الهاتف غير متوفر" : phone,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color? color,
    bool isLoading = false,
  }) {
    final bool isLogoutItem = (color == Colors.red);

    final Color activeIconColor = isLogoutItem ? Colors.red : Get.theme.primaryColor;

    final Color activeTextColor =
        isLogoutItem ? Colors.red : (color ?? AppThemes.primaryNavy);

    return Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall / 4),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSmall,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isLoading ? Colors.grey.shade200 : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: isLoading ? null : onTap,
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Icon(
                  icon,
                  color: isLoading ? Colors.grey : activeIconColor,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    color: isLoading ? Colors.grey : activeTextColor,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: isLoading ? Colors.grey : activeIconColor,
              ),
            ],
          ),
        ),
      );
  }
}
