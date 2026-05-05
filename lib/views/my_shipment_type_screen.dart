import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/logic/controller/add_shipment_type_controller.dart';
import 'package:piaggio_driver/logic/controller/my_shipment_type_controller.dart';
import 'package:piaggio_driver/model/shipment_type_model.dart';

class MyShipmentTypeScreen extends StatelessWidget {
  MyShipmentTypeScreen({super.key});

  final MyShipmentTypeController shipmentTypeCtrl =
      Get.put(MyShipmentTypeController());
  final AddShipmentTypeController addCtrl =
      Get.put(AddShipmentTypeController());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "أنواع البضاعة",
            style: TextStyle(color: AppThemes.primaryNavy, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: AppThemes.primaryNavy, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Obx(() {
              if (shipmentTypeCtrl.isLoading.value) {
                return Center(
                    child: CircularProgressIndicator(
                  color: AppThemes.primaryNavy,
                ));
              }
              if (shipmentTypeCtrl.error.isNotEmpty) {
                return Center(child: Text(shipmentTypeCtrl.error.value));
              }

              return Column(
                children: [
                  Expanded(
                    child: Obx(() {
                      final _ = shipmentTypeCtrl.selected.length;
                      return _ShipmentTypeGrid(
                        items: shipmentTypeCtrl.types,
                        onToggle: shipmentTypeCtrl.toggle,
                        controller: shipmentTypeCtrl,
                      );
                    }),
                  ),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemes.primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            15,
                          ),
                        ),
                        minimumSize: const Size(
                            double.infinity, AppDimensions.buttonHeight),
                      ),
                      onPressed: () =>
                          addCtrl.send(shipmentTypeCtrl.selectedIds),
                      child: const Text('حفظ'),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _ShipmentTypeGrid extends StatelessWidget {
  const _ShipmentTypeGrid({
    required this.items,
    required this.onToggle,
    required this.controller,
  });

  final List<ShipmentTypeModel> items;
  final void Function(ShipmentTypeModel) onToggle;
  final MyShipmentTypeController controller;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 110,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, i) {
        final item = items[i];
        final isChosen = controller.selected.any((e) => e.id == item.id);

        return GestureDetector(
          onTap: () => onToggle(item),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isChosen ? AppThemes.primaryOrange : Colors.grey.shade300,
                width: isChosen ? 2 : 1,
              ),
              color:
                  isChosen ? AppThemes.primaryOrange.withValues(alpha: .08) : Colors.white,
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _typeImage(item, isChosen),
                const SizedBox(height: 8),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isChosen ? FontWeight.bold : FontWeight.normal,
                    color: isChosen ? AppThemes.primaryOrange : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _typeImage(ShipmentTypeModel t, bool chosen) {
    if (t.image != null && t.image!.isNotEmpty) {
      return Image.network(
        t.image!,
        height: 42,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2, size: 42),
      );
    }
    return Icon(Icons.inventory_2,
        size: 42, color: chosen ? AppThemes.primaryOrange : Colors.grey);
  }
}
