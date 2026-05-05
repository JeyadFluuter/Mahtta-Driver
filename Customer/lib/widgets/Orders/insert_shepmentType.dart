// ignore: file_names
import '../../logic/controller/shipment_types_controller.dart';
import 'package:biadgo/models/shipment_types_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:biadgo/constants/app_theme.dart';
import '../../constants/app_dimensions.dart';

class InsertShepmenttype extends StatelessWidget {
  InsertShepmenttype({super.key});

  final ShipmentTypesController shipmentTypesController =
      Get.put(ShipmentTypesController());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
        child: Obx(() {
          if (shipmentTypesController.isLoading.value) {
            return _buildShimmerSkeleton();
          }

          final typesList = shipmentTypesController.shipmentTypes
              .where((item) => item.id > 0)
              .toList();

          final selectedId =
              shipmentTypesController.selectedShipmentTypeId.value;

          final dataShipmentTypes? selectedItem =
              typesList.firstWhereOrNull((type) => type.id == selectedId);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'نوع البضاعة',
                style: TextStyle(
                  color: AppThemes.primaryNavy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              if (typesList.isEmpty)
                const Text("لا توجد بضائع متاحة حالياً", style: TextStyle(color: Colors.grey))
              else
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: typesList.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.paddingSmall),
                    itemBuilder: (context, index) {
                      final typeItem = typesList[index];
                      final isSelected = typeItem.id == selectedId;
                      return GestureDetector(
                        onTap: () => shipmentTypesController.setSelectedShipmentType(typeItem.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 95,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? Get.theme.primaryColor.withValues(alpha: .08) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Get.theme.primaryColor : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              (typeItem.image != null && typeItem.image!.isNotEmpty)
                                  ? Image.network(
                                      typeItem.image!,
                                      height: 35,
                                      width: 35,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.inventory_2_outlined,
                                        color: isSelected ? Get.theme.primaryColor : Colors.grey,
                                      ),
                                    )
                                  : Icon(
                                      Icons.inventory_2_outlined,
                                      color: isSelected ? Get.theme.primaryColor : Colors.grey,
                                      size: 35,
                                    ),
                              const SizedBox(height: 8),
                              Text(
                                typeItem.name ?? '',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Get.theme.primaryColor : AppThemes.primaryNavy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (selectedItem != null && selectedItem.isAutoDispose == 1) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: .05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "إذا لم يكن لديك موقع للتفريغ، اترك الحقل الثاني فارغًا؛ التفريغ يتم تلقائيًا من قبل السائق",
                          style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (selectedItem != null && selectedItem.isAutoDispose == 0) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: .05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "يجب عليك إدخال النقطة الأولى والنقطة الثانية",
                          style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _buildShimmerSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نوع البضاعة',
          style: TextStyle(
            color: AppThemes.primaryNavy,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppDimensions.paddingSmall),
            itemBuilder: (_, __) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 95,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
