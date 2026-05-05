import 'package:biadgo/constants/app_dimensions.dart';
import 'package:biadgo/logic/controller/estimate_order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InformationOrders extends StatelessWidget {
  InformationOrders({super.key});

  final EstimateOrderController estimateOrderController =
      Get.find<EstimateOrderController>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: AppDimensions.screenHeight * 0.5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            final dataEsimate = estimateOrderController.dataEsimate.value;
            if (dataEsimate == null) {
              return Center(
                  child: CircularProgressIndicator(
                color: Get.theme.primaryColor,
              ));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "الموقع",
                  style: TextStyle(
                    fontSize: 16,
                    color: Get.theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/map.jpg',
                    height: AppDimensions.screenHeight * 0.3,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSmall),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoText("الوقت المتوقع",
                          dataEsimate.estimatedTime ?? "غير متوفر"),
                      _buildInfoText(
                          "المسافة المتوقعة", "${dataEsimate.distance} كلم"),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
                Divider(color: Get.theme.primaryColor, thickness: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSmall),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "سعر الطلب : ${dataEsimate.priceEstimated} د.ل",
                      style: TextStyle(
                          color: Get.theme.primaryColor,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

Widget _buildInfoText(String title, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 15,
          color: Get.theme.primaryColor,
        ),
      ),
      const SizedBox(
        height: AppDimensions.paddingSmall,
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Get.theme.primaryColor,
        ),
      ),
    ],
  );
}
