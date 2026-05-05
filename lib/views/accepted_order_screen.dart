import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/logic/controller/logout_controller.dart';
import 'package:piaggio_driver/logic/controller/me_controller.dart';
import 'package:piaggio_driver/logic/controller/offer_notification_controller.dart';
import 'package:piaggio_driver/logic/controller/order_request_controller.dart';
import 'package:piaggio_driver/widgets/custom_google_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:piaggio_driver/widgets/order_request_info.dart';

class AcceptedOrderScreen extends StatefulWidget {
  const AcceptedOrderScreen({super.key});

  @override
  State<AcceptedOrderScreen> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<AcceptedOrderScreen> {
  final LogOutController logOutController = Get.put(LogOutController());
  final MeController meController = Get.put(MeController());
  final OfferNotificationController offerCtrl =
      Get.put(OfferNotificationController());
  final OrderController orderCtrl = Get.find<OrderController>();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          final order = orderCtrl.currentOrder.value;
          return CustomGoogleMap(
            bottomPadding: order != null ? 400 : 0,
          );
        }),
        const Padding(

          padding: EdgeInsets.only(top: AppDimensions.paddingLarge),
          child: Align(
            alignment: Alignment.topCenter,
            child: Text("أنت متصل بالطلب"),
          ),
        ),
        Obx(() {
          final order = orderCtrl.currentOrder.value;
          if (order == null) return const SizedBox.shrink();
          return OrderInfoCard(
            order: order,
          );
        }),
      ],
    );
  }
}
