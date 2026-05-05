import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/logic/controller/location_controller.dart';
import 'package:piaggio_driver/logic/controller/me_controller.dart';
import 'package:piaggio_driver/logic/controller/offer_notification_controller.dart';
import 'package:piaggio_driver/logic/controller/logout_controller.dart';
import 'package:piaggio_driver/views/Auth/change_password_screen.dart';
import 'package:piaggio_driver/views/Customer_services_screen.dart';
import 'package:piaggio_driver/views/info_app_screen.dart';
import 'package:piaggio_driver/views/my_order_screen.dart';
import 'package:piaggio_driver/views/my_shipment_type_screen.dart';
import 'package:piaggio_driver/views/offers_screen.dart';
import 'package:piaggio_driver/views/profits_screen.dart';
import 'package:piaggio_driver/views/statistics_screen.dart';
import 'package:piaggio_driver/views/terms_policies_screen.dart';
import 'package:piaggio_driver/views/wallet_screen.dart';
import 'package:piaggio_driver/views/settings_profile_screen.dart';
import 'package:piaggio_driver/widgets/home_screen_2.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final LogOutController logOutController = Get.put(LogOutController());
  final MeController meController = Get.put(MeController());
  final OfferNotificationController offerCtrl =
      Get.put(OfferNotificationController());
  final locationController = Get.put(LocationController());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: AppThemes.primaryNavy),
          leading: Obx(() {
            return IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.menu, size: 28),
                  if (offerCtrl.unreadCount.value > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          offerCtrl.unreadCount.value.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            );
          }),
          title: Obx(() {
            final first = meController.firstname.value;
            final last = meController.lastname.value;
            if (first.isEmpty && last.isEmpty) {
              return Column(
                children: [
                  Text(
                    "مرحباً زبوننا العزيز",
                    style: TextStyle(
                      color: AppThemes.primaryNavy,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "نتمنى لك يوماً مباركاً",
                    style: TextStyle(
                      color: AppThemes.primaryNavy,
                      fontSize: 14,
                    ),
                  )
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "مرحباً $first $last",
                  style: TextStyle(
                    color: AppThemes.primaryNavy,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmallX),
                Text(
                  "نتمنى لك يوماً مباركاً",
                  style: TextStyle(fontSize: 12, color: AppThemes.primaryNavy),
                )
              ],
            );
          }),
        ),
        onDrawerChanged: (isOpen) {
          if (isOpen) {
            meController.refreshMe();
          }
        },
        drawer: Drawer(
          backgroundColor: const Color(0xFFF8F9FA),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              bottomLeft: Radius.circular(28),
            ),
          ),
          width: MediaQuery.of(context).size.width * 0.75,
          child: Column(
            children: [
              // ════════════════════════════
              // HEADER (Compact)
              // ════════════════════════════
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  bottom: 16,
                  left: 18,
                  right: 18,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppThemes.primaryOrange, Color(0xFFE67E22)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row: Avatar + Name/Phone
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => SettingsProfileScreen());
                      },
                      child: Row(
                        children: [
                          // Avatar
                          Obx(() => Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2.5),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [AppThemes.primaryOrange, Color(0xFFFFB347)],
                                  ),
                                ),
                                child: ClipOval(
                                  child: meController.driverImage.value.isNotEmpty
                                      ? Image.network(
                                          meController.driverImage.value,
                                          width: 58,
                                          height: 58,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Image.asset(
                                            "assets/images/profile2.png",
                                            width: 58, height: 58, fit: BoxFit.cover,
                                          ),
                                        )
                                      : Image.asset(
                                          "assets/images/profile2.png",
                                          width: 58, height: 58, fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: AppThemes.primaryOrange,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.2),
                                ),
                                child: const Icon(Icons.edit_rounded, size: 8, color: Colors.white),
                              ),
                            ],
                          )),
                          const SizedBox(width: 12),
                          // Name + Phone
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() {
                                  final name = '${meController.firstname.value} ${meController.lastname.value}'.trim();
                                  return Text(
                                    name.isEmpty || name == 'null null' ? 'سائقنا المتميز' : name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                }),
                                const SizedBox(height: 4),
                                Obx(() {
                                  final phone = meController.phone.value.trim();
                                  return Row(
                                    children: [
                                      Icon(Icons.phone_rounded, size: 11, color: Colors.white.withOpacity(0.5)),
                                      const SizedBox(width: 4),
                                      Text(
                                        phone.isEmpty || phone == 'null' ? 'لا يوجد رقم' : phone,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Status Bar
                    Obx(() {
                      final isActive = meController.isActive.value == '1';
                      final rating = meController.averageRating.value;
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildHeaderStat("الحالة", isActive ? "نشط" : "غير نشط", Icons.circle, isActive ? Colors.greenAccent : Colors.redAccent),
                            Container(height: 16, width: 0.8, color: Colors.white.withOpacity(0.2)),
                            _buildHeaderStat("التقييم", rating > 0 ? rating.toStringAsFixed(1) : "--", Icons.star_rounded, Colors.amber),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),


              // ════════════════════════════
              // MENU ITEMS
              // ════════════════════════════
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Main Section
                    _buildSectionLabel("القائمة الرئيسية"),
                    _buildDrawerItem(context, icon: Icons.home_rounded, title: 'الرئيسية', onTap: () => Navigator.pop(context), isSelected: true),
                    _buildDrawerItem(context, icon: Icons.inventory_2_rounded, title: 'أنواع الشحنات', onTap: () { Navigator.pop(context); Get.to(() => MyShipmentTypeScreen()); }),
                    _buildDrawerItem(context, icon: Icons.local_shipping_rounded, title: 'أرشيف الطلبات', onTap: () { Navigator.pop(context); Get.to(() => MyOrderScreen()); }),
                    _buildDrawerItem(context, icon: Icons.account_balance_wallet_rounded, title: 'المحفظة الرقمية', onTap: () { Navigator.pop(context); Get.to(() => WalletScreen()); }),
                    _buildDrawerItem(context, icon: Icons.bar_chart_rounded, title: 'الأرباح والإحصائيات', onTap: () { Navigator.pop(context); Get.to(() => ProfitsScreen()); }),
                    Obx(() => _buildDrawerItem(
                      context,
                      icon: Icons.local_offer_rounded,
                      title: 'العروض الحصرية',
                      trailing: offerCtrl.unreadCount.value > 0
                          ? Container(
                              width: 20, height: 20,
                              decoration: const BoxDecoration(color: AppThemes.primaryOrange, shape: BoxShape.circle),
                              child: Center(child: Text(offerCtrl.unreadCount.value.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                            )
                          : null,
                      onTap: () { Navigator.pop(context); offerCtrl.markRead(); Get.to(() => OffersScreen()); },
                    )),

                    // Divider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: Divider(thickness: 0.8, color: Colors.grey.shade200),
                    ),

                    // Support Section
                    _buildSectionLabel("المساعدة والدعم"),
                    _buildDrawerItem(context, icon: Icons.headset_mic_rounded, title: 'الدعم الفني', onTap: () { Navigator.pop(context); Get.to(() => const CustomerServicesScreen()); }),
                    _buildDrawerItem(context, icon: Icons.info_outline_rounded, title: 'حول التطبيق', onTap: () { Navigator.pop(context); Get.to(() => const InfoApp()); }),
                    _buildDrawerItem(context, icon: Icons.shield_outlined, title: 'الشروط والأحكام', onTap: () { Navigator.pop(context); Get.to(() => const TermsPoliciesScreen()); }),
                    _buildDrawerItem(context, icon: Icons.manage_accounts_rounded, title: 'إعدادات الحساب', onTap: () { Navigator.pop(context); Get.to(() => SettingsProfileScreen()); }),
                  ],
                ),
              ),

              // ════════════════════════════
              // LOGOUT BUTTON
              // ════════════════════════════
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: logOutController.isLoading.value ? null : () => logOutController.logout(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppThemes.primaryOrange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: logOutController.isLoading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout_rounded, size: 18, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text(
                                    'تسجيل الخروج',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
        body: const HomeScreen2(),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 12, left: 8, top: 4, bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap,
      bool isSelected = false,
      Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppThemes.primaryOrange.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isSelected
                ? AppThemes.primaryOrange.withOpacity(0.15)
                : AppThemes.primaryNavy.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected ? AppThemes.primaryOrange : AppThemes.primaryNavy.withOpacity(0.65),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppThemes.primaryOrange : AppThemes.primaryNavy,
          ),
        ),
        trailing: trailing ??
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isSelected ? AppThemes.primaryOrange : Colors.grey.shade400,
            ),
        onTap: onTap,
        splashColor: AppThemes.primaryOrange.withOpacity(0.1),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 9, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

