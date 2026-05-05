import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/logic/controller/logout_controller.dart';
import 'package:piaggio_driver/logic/controller/me_controller.dart';
import 'package:piaggio_driver/logic/controller/offer_notification_controller.dart';
import 'package:piaggio_driver/logic/controller/order_request_controller.dart';
import 'package:piaggio_driver/logic/controller/status_controller.dart';
import 'package:piaggio_driver/widgets/custom_google_map.dart';
import 'package:piaggio_driver/widgets/order_request_info.dart';
import 'package:piaggio_driver/widgets/step_vehicles.dart';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  State<HomeScreen2> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
  final LogOutController logOutController = Get.put(LogOutController());
  final StatusController statusController = Get.put(StatusController());
  final MeController meController = Get.put(MeController());
  final OfferNotificationController offerCtrl =
      Get.put(OfferNotificationController());
  final OrderController orderCtrl = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          final hasOrder = orderCtrl.currentOrder.value != null;
          return CustomGoogleMap(
            showEditZone: true,
            bottomPadding: hasOrder ? 400 : 0,
          );
        }),
        Obx(() {
          final isPending = meController.status.value == "قيد الانتظار";
          final isActive = statusController.isActivated.value && !isPending;

          return isActive
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.grey.withValues(alpha: 0.7),
                  child: const Center(
                    child: Text(
                      "أنت غير متصل",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
        }),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
                top: AppDimensions.paddingMediumX,
                left: AppDimensions.paddingSmall,
                right: AppDimensions.paddingSmall),
            child: Align(
              alignment: Alignment.topCenter,
              child: Obx(
                () {
                  final isPending = meController.status.value == "قيد الانتظار";
                  final isActive =
                      statusController.isActivated.value && !isPending;
                  return Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingSmallX),
                    child: Container(
                      height: AppDimensions.paddingLarge * 5,
                      width: AppDimensions.paddingLarge * 15,
                      decoration: BoxDecoration(
                        color: isActive ? AppThemes.primaryOrange : AppThemes.primaryNavy,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.buttonRadius),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.all(AppDimensions.paddingMedium),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isActive ? 'متصل' : 'غير متصل',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: AppDimensions.paddingSmall,
                                ),
                                Text(
                                  isActive
                                      ? "أنت الآن في وضع استقبال الطلبات"
                                      : "أنت غير في وضع عدم إستقبال الطلبات",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                              ],
                            ),
                            Switch(
                              value: isActive,
                              onChanged: isPending
                                  ? null
                                  : (value) async {
                                      try {
                                        await statusController
                                            .toggleActivation();
                                      } catch (e) {
                                        debugPrint(e.toString());
                                      }
                                    },
                              activeColor: Colors.white,
                              inactiveThumbColor: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        SafeArea(
          child: Obx(() {
            final currentStatus = meController.status.value.trim();
            final hideOverlay = (currentStatus == "معتمد" ||
                    currentStatus.toLowerCase() == "approved" ||
                    currentStatus.toLowerCase() == "active") &&
                meController.isApproved.value == true;
            if (hideOverlay) return const SizedBox.shrink();
            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: AppDimensions.screenHeight * .25,
                color: Colors.grey,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning, color: Colors.yellow, size: 25),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    const Text(
                      "قيد التسجيل",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    Text(
                      meController.hasVehicleData.value == false
                          ? "تم إرسال طلب إنشاء الحساب وهو قيد المراجعة.\nأدخل بيانات المركبة لاستكمال الطلب."
                          : "تم إرسال بيانات المركبة وهي قيد المراجعة.\nالرجاء الانتظار لحين اعتمادها من موظفي الشركة.",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    if (meController.hasVehicleData.value == false)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppThemes.primaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.buttonRadius),
                          ),
                          fixedSize: Size(
                            AppDimensions.screenWidth * .7,
                            AppDimensions.screenHeight * .05,
                          ),
                        ),
                        onPressed: () => Get.to(() => const StepVehicles()),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: AppDimensions.paddingSmall),
                            Text(
                              "إدخال بيانات المركبة",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
        Obx(() {
          final order = orderCtrl.currentOrder.value;
          if (order == null) return const SizedBox.shrink();
          return OrderInfoCard(order: order);
        }),
      ],
    );
  }
}
