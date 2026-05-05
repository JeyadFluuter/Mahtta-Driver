/* lib/views/vehicles_and_locations_screen_cargo.dart */
import 'package:biadgo/constants/app_dimensions.dart';
import 'package:biadgo/logic/controller/map_controller2.dart';
import 'package:biadgo/logic/controller/vehicle_category_controller.dart';
import 'package:biadgo/models/vehicle_types_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:biadgo/constants/app_theme.dart';


class VehiclesAndLocationsScreenCargo extends StatelessWidget {
  VehiclesAndLocationsScreenCargo({super.key});

  final VehicleCategoryController c = Get.put(VehicleCategoryController());
  final MapController2 mapCtrl = Get.find<MapController2>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Obx(() {
        // ننتظر فقط تحميل الفئات الأساسية، ولا نعطل العرض بسبب انتظار السعر
        if (c.isLoading.value) {
          return _buildShimmerSkeleton();
        }

        if (c.categories.isEmpty) {
          return const Center(child: Text('لا توجد مركبات متاحة'));
        }

        final vehicles = c.getVehiclesForSelectedCategory();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _title('فئة المركبة'),
            const SizedBox(height: AppDimensions.paddingSmall),
            Padding(
              padding:
                  const EdgeInsets.only(right: AppDimensions.paddingMedium),
              child: _CategoriesRow(controller: c),
            ),
            if (vehicles.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.paddingMedium),
              _title('نوع المركبة'),
              const SizedBox(height: AppDimensions.paddingSmall),
              Padding(
                padding:
                    const EdgeInsets.only(right: AppDimensions.paddingMedium),
                child: _VehiclesRow(
                    controller: c, mapCtrl: mapCtrl, vehicles: vehicles),
              ),
            ],
            Obx(() {
              if (mapCtrl.estimateError.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Text(
                  mapCtrl.estimateError.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              );
            }),
          ],
        );
      }),
    );
  }

  Widget _buildShimmerSkeleton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _title('فئة المركبة'),
        const SizedBox(height: AppDimensions.paddingSmall),
        SizedBox(
          height: AppDimensions.screenHeight * .12,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.paddingSmall),
            itemCount: 4,
            itemBuilder: (_, __) => _shimmerItem(width: AppDimensions.screenWidth * .28, height: AppDimensions.screenHeight * .09),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        _title('نوع المركبة'),
        const SizedBox(height: AppDimensions.paddingSmall),
        SizedBox(
          height: AppDimensions.screenHeight * .19,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.paddingSmall),
            itemCount: 4,
            itemBuilder: (_, __) => _shimmerItem(width: AppDimensions.screenWidth * .28, height: AppDimensions.screenHeight * .09, hasPrice: true),
          ),
        ),
      ],
    );
  }

  Widget _shimmerItem({required double width, required double height, bool hasPrice = false}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 8),
          Container(width: width * 0.7, height: 12, color: Colors.white),
          if (hasPrice) ...[
            const SizedBox(height: 8),
            Container(width: width * 0.5, height: 10, color: Colors.white),
          ]
        ],
      ),
    );
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(right: AppDimensions.paddingMedium),
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(t, style: const TextStyle(fontSize: 16, color: AppThemes.primaryNavy, fontWeight: FontWeight.bold)),
        ),
      );
}


class _CategoriesRow extends StatelessWidget {
  const _CategoriesRow({required this.controller});
  final VehicleCategoryController controller;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: AppDimensions.screenHeight * .12,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppDimensions.paddingSmall),
            itemCount: controller.categories.length,
            itemBuilder: (_, i) =>
                _CategoryItem(cat: controller.categories[i], c: controller),
          ),
        ),
      );
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.cat, required this.c});

  final VehicleCategory cat;
  final VehicleCategoryController c;

  @override
  Widget build(BuildContext context) {
    final mapCtrl = Get.find<MapController2>();

    return Obx(() {
      final isSelected = cat.id == c.selectedCategoryId.value;
      final isEnabled = mapCtrl.categoryHasAvailableVehicle(cat);
      if (!isEnabled && isSelected) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          c.selectCategory(0);
        });
      }
      const radius = BorderRadius.all(Radius.circular(10));
      final card = ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: AppDimensions.screenHeight * .09,
              width: AppDimensions.screenWidth * .28,
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(
                  color: isSelected ? Get.theme.primaryColor : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                color: isSelected
                    ? Get.theme.primaryColor.withValues(alpha: .08)
                    : Colors.white,
              ),
              child: (cat.image?.isNotEmpty ?? false)
                  ? Image.network(
                      cat.image!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.local_shipping_rounded,
                              size: 40, color: Get.theme.primaryColor),
                    )
                  : Icon(Icons.local_shipping_rounded,
                      size: 40, color: Get.theme.primaryColor),
            ),
            if (!isEnabled)
              Positioned.fill(
                child: Container(
                    color: Colors.grey.withValues(alpha: .55),
                    alignment: Alignment.center,
                    child: Container()),
              ),
          ],
        ),
      );

      final title = SizedBox(
        width: AppDimensions.screenWidth * .28,
        child: Text(
          cat.name ?? '',
          maxLines: 2,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSelected ? 13 : 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
            color: isEnabled
                ? (isSelected ? Get.theme.primaryColor : Colors.black)
                : Colors.grey,
          ),
        ),
      );

      final content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          card,
          const SizedBox(height: 5),
          title,
        ],
      );

      return isEnabled
          ? GestureDetector(
              onTap: () => c.selectCategory(cat.id), child: content)
          : content;
    });
  }
}

class _VehiclesRow extends StatelessWidget {
  const _VehiclesRow(
      {required this.controller,
      required this.mapCtrl,
      required this.vehicles});

  final VehicleCategoryController controller;
  final MapController2 mapCtrl;
  final List<Vehicle> vehicles;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: AppDimensions.screenHeight * .19,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppDimensions.paddingSmall),
            itemCount: vehicles.length,
            itemBuilder: (_, i) =>
                _VehicleItem(v: vehicles[i], c: controller, mapCtrl: mapCtrl),
          ),
        ),
      );
}

class _VehicleItem extends StatelessWidget {
  const _VehicleItem({required this.v, required this.c, required this.mapCtrl});
  final Vehicle v;
  final VehicleCategoryController c;
  final MapController2 mapCtrl;

  @override
  Widget build(BuildContext context) => Obx(() {
        final sel = v.id == c.selectedVehicleId.value;

        return GestureDetector(
          onTap: () => c.selectVehicle(v.id),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: AppDimensions.screenWidth * .28,
                height: AppDimensions.screenHeight * .09,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: sel ? Get.theme.primaryColor : Colors.grey.shade300,
                      width: sel ? 2 : 1),
                  color:
                      sel ? Get.theme.primaryColor.withValues(alpha: .08) : Colors.white,
                ),
                child: (v.image?.isNotEmpty ?? false)
                    ? Image.network(v.image!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            Image.asset('assets/images/2.png'))
                    : Image.asset('assets/images/2.png'),
              ),
              const SizedBox(height: AppDimensions.paddingSmallX),
              SizedBox(
                width: AppDimensions.screenWidth * .28,
                child: Text(v.name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: sel ? 12 : 11,
                        fontWeight: sel ? FontWeight.bold : FontWeight.w400,
                        color: sel ? Get.theme.primaryColor : Colors.black)),
              ),
              _priceTag(v),
            ],
          ),
        );
      });

  Widget _priceTag(Vehicle v) => Obx(() {
        if (mapCtrl.priceLoading.value) {
          return const Padding(
            padding: EdgeInsets.only(top: AppDimensions.paddingSmall),
            child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 1)),
          );
        }
        final price = mapCtrl.vehiclePrices.firstWhereOrNull(
            (e) => int.tryParse(e['vehicle_type_id'].toString()) == v.id)?['estimated_price'];
        if (price == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Get.theme.primaryColor.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('$price د.ل',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Get.theme.primaryColor)),
          ),
        );
      });
}
