import 'package:biadgo/constants/app_dimensions.dart';
import 'package:biadgo/logic/controller/vehicle_category_controller.dart';
import 'package:biadgo/models/vehicle_types_model.dart';
import 'package:biadgo/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:biadgo/constants/app_theme.dart';

class VehiclesAndLocationsScreenHome extends StatelessWidget {
  VehiclesAndLocationsScreenHome({super.key});

  final VehicleCategoryController controller =
      Get.put(VehicleCategoryController());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.only(right: AppDimensions.paddingSmall),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'فئات المركبات',
                style: const TextStyle(
                  color: AppThemes.primaryNavy,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Obx(() {
              if (controller.isLoading.value) {
                return Center(
                    child: CircularProgressIndicator(
                  color: Get.theme.primaryColor,
                ));
              }
              if (controller.categories.isEmpty) {
                return const Center(child: Text('لا توجد سيارات متاحة'));
              }
              return SizedBox(
                height: AppDimensions.screenHeight * .12,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.categories.length,
                  itemBuilder: (_, i) {
                    final cat = controller.categories[i];

                    return GestureDetector(
                      onTap: () => _showVehicleBottomSheet(context, cat),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: AppDimensions.screenHeight * .09,
                            width: AppDimensions.screenWidth * .26,
                            margin: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingSmall),
                            padding: const EdgeInsets.all(
                                AppDimensions.paddingSmall),
                            child: (cat.image != null && cat.image!.isNotEmpty)
                                ? Image.network(
                                    cat.image!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) =>
                                        Icon(Icons.local_shipping_rounded,
                                            size: 40, color: AppThemes.primaryOrange),
                                  )
                                : Icon(Icons.local_shipping_rounded,
                                    size: 40, color: AppThemes.primaryOrange),
                          ),
                          Text(
                            cat.name ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppThemes.primaryNavy,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showVehicleBottomSheet(BuildContext ctx, VehicleCategory cat) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (cat.image != null && cat.image!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      cat.image!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.local_shipping_rounded,
                              size: 80, color: Get.theme.primaryColor),
                    ),
                  )
                else
                  Icon(Icons.local_shipping_rounded,
                      size: 80, color: Get.theme.primaryColor),
                Text(cat.name ?? '',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: AppThemes.primaryNavy)),
                const SizedBox(height: 8),
                if (cat.vehicles.isNotEmpty)
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      itemCount: cat.vehicles.length,
                      itemBuilder: (_, i) {
                        final v = cat.vehicles[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: (v.image?.isNotEmpty ?? false)
                              ? SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      v.image!,
                                      fit: BoxFit.contain,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Get.theme.primaryColor,
                                              strokeWidth: 2,
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      (loadingProgress
                                                          .expectedTotalBytes!)
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (_, __, ___) => const Icon(
                                          Icons.directions_car,
                                          size: 32),
                                    ),
                                  ),
                                )
                              : const Icon(Icons.directions_car, size: 32),
                          title: Text(v.name ?? '',
                              style: const TextStyle(fontSize: 14)),
                        );
                      },
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, thickness: .4),
                    ),
                  )
                else
                  const Text('لا توجد مركبات ضمن هذه الفئة.'),
                const SizedBox(height: 20),

                /* زر إغلاق */
                Button(
                  name: 'رجوع',
                  onPressed: () => Get.back(),
                  size: Size(
                      AppDimensions.screenWidth * .4, AppDimensions.buttonHeight),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
