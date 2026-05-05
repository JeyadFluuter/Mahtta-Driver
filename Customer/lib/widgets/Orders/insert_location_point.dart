import 'package:biadgo/constants/app_dimensions.dart';
import 'package:biadgo/logic/controller/map_controller2.dart';
import '../../logic/controller/shipment_types_controller.dart';
import 'package:biadgo/widgets/Orders/pickPointScreen2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:biadgo/constants/app_theme.dart';

class InsertLocationPoint extends StatelessWidget {
  final MapController2 mapController2 = Get.find();
  final ShipmentTypesController shipmentTypesController = Get.find();

  InsertLocationPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Obx(() {
        final hasFirst = mapController2.firstLocation.value != null;
        final hasSecond = mapController2.secondLocation.value != null;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Timeline indicators
                Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AppThemes.pinAColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (shipmentTypesController.selectedShipmentType?.isAutoDispose != 1) ...[
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: Colors.grey.shade300,
                        ),
                      ),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppThemes.pinBColor,
                          borderRadius: BorderRadius.circular(3), // Square look
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
                const SizedBox(width: 16),
                // Text Inputs
                Expanded(
                  child: Column(
                    children: [
                      // First Point
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Get.to(() => const PickPointScreen2(isFirstPoint: true)),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    mapController2.addressLoading.value
                                        ? 'جاري جلب العنوان...'
                                        : mapController2.firstAddress.value.isNotEmpty
                                            ? mapController2.firstAddress.value
                                            : hasFirst
                                                ? 'تم اختيار النقطة الأولى'
                                                : 'حدد موقع الالتقاط',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: hasFirst ? AppThemes.primaryNavy : Colors.grey.shade600,
                                      fontWeight: hasFirst ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                hasFirst
                                    ? GestureDetector(
                                        onTap: () {
                                          mapController2.clearFirstLocation();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Icon(Icons.close, color: Colors.red.shade300, size: 20),
                                        ),
                                      )
                                    : Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Divider(color: Colors.grey.shade200, height: 16),
                      // Second Point
                      Material(
                        color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Get.to(() => const PickPointScreen2(isFirstPoint: false)),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      mapController2.addressLoading.value
                                          ? 'جاري جلب العنوان...'
                                          : mapController2.secondAddress.value.isNotEmpty
                                              ? mapController2.secondAddress.value
                                              : hasSecond
                                                  ? 'تم اختيار النقطة الثانية'
                                                  : 'حدد موقع التسليم',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: hasSecond ? AppThemes.primaryNavy : Colors.grey.shade600,
                                        fontWeight: hasSecond ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  hasSecond
                                      ? GestureDetector(
                                          onTap: () {
                                            mapController2.clearSecondLocation();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Icon(Icons.close, color: Colors.red.shade300, size: 20),
                                          ),
                                        )
                                      : Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      // End of Second Point
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
