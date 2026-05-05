import 'package:biadgo/constants/app_dimensions.dart';
import 'package:biadgo/logic/controller/logout_controller.dart';
import 'package:biadgo/logic/controller/map_controller2.dart';
import 'package:biadgo/logic/controller/me_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../logic/controller/navbar_controller.dart';
import '../logic/controller/profile_controller.dart';
import '../logic/controller/my_order_controller.dart';
import '../views/home_screen.dart';
import '../views/profile_screen.dart';
import '../views/my_order_screen1.dart';
import 'Orders/make_order.dart';

class NavBar extends StatelessWidget {
  final controller = Get.put(NavBarController());
  final myOrderController = Get.put(MyOrderController(), permanent: true);

  NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavBarController>(
      builder: (_) => Scaffold(
        // key: mainScaffoldKey,
        body: IndexedStack(
          index: controller.tabIndex,
          children: [
            HomeScreen(),
            if (controller.tabIndex == 1)
              Builder(
                builder: (_) {
                  if (!Get.isRegistered<MapController2>()) {
                    Get.put(MapController2());
                  }
                  return const MakeOrder();
                },
              )
            else
              const SizedBox(),
            if (controller.tabIndex == 2)
              MyOrderScreen1()
            else
              const SizedBox(),
            if (controller.tabIndex == 3)
              Builder(
                builder: (_) {
                  if (!Get.isRegistered<ProfileController>()) {
                    Get.put(ProfileController());
                  }
                  if (!Get.isRegistered<LogOutController>()) {
                    Get.put(LogOutController());
                  }
                  if (!Get.isRegistered<MeController>()) {
                    Get.put(MeController());
                  }
                  return ProfileScreen();
                },
              )
            else
              const SizedBox(),
          ],
        ),
        bottomNavigationBar: FancyPillNavBar(
          controller: controller,
          myOrderController: myOrderController,
        ),
      ),
    );
  }
}

class FancyPillNavBar extends StatelessWidget {
  final NavBarController controller;
  final MyOrderController myOrderController;

  const FancyPillNavBar({
    super.key,
    required this.controller,
    required this.myOrderController,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ["الرئيسية", "طلب شحنة", "الطلبات", "الحساب"];
    const icons = [
      Icons.home_outlined,
      Icons.local_shipping_outlined,
      Icons.history_outlined,
      Icons.person_outline,
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppDimensions.paddingSmallX,
          right: AppDimensions.paddingSmallX,
          bottom: AppDimensions.paddingSmallX,
        ),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Get.theme.primaryColor,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (i) {
              final isSelected = controller.tabIndex == i;
              if (i == 2) {
                return Obx(() {
                  final showBadge = myOrderController.hasAcceptedOrder.value;
                  return _pillItem(
                    index: i,
                    icon: icons[i],
                    label: labels[i],
                    isSelected: isSelected,
                    showBadge: showBadge,
                  );
                });
              }
              return _pillItem(
                index: i,
                icon: icons[i],
                label: labels[i],
                isSelected: isSelected,
                showBadge: false,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _pillItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool showBadge,
  }) {
    return GestureDetector(
      onTap: () => controller.changeTabIndex(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSmall,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          height: 40,
          width: isSelected ? 100 : 55,
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingSmall),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    mainAxisAlignment: isSelected
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: isSelected ? Colors.white : Colors.white54,
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: AppDimensions.paddingSmallX),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (showBadge)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
