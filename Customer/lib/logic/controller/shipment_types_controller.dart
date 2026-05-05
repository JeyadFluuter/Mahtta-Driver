import 'package:biadgo/models/shipment_types_model.dart';
import 'package:biadgo/services/shipment_types_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShipmentTypesController extends GetxController {
  RxList<dataShipmentTypes> shipmentTypes = RxList<dataShipmentTypes>();
  var isLoading = true.obs;
  RxInt selectedShipmentTypeId = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  dataShipmentTypes? get selectedShipmentType => shipmentTypes.firstWhereOrNull((t) => t.id == selectedShipmentTypeId.value);

  getMyShipmentTypes() async {
    try {
      isLoading(true);
      shipmentTypes.clear();

      var response = await ShipmentTypesServices().shipmentTypesData();
      debugPrint("response = $response");

      if (response.isNotEmpty) {
        shipmentTypes.addAll(response as Iterable<dataShipmentTypes>);
      } else {
        debugPrint("لا توجد بيانات متاحة");
      }
    } catch (e) {
      debugPrint("خطأ في جلب البيانات: $e");
    } finally {
      isLoading(false);
      update();
    }
  }

  void setSelectedShipmentType(int id) {
    selectedShipmentTypeId.value = id;
    debugPrint("تم اختيار نوع البضائع: $id");
  }
}
