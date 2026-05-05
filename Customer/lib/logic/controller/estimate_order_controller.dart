import 'package:biadgo/logic/controller/new_location1_controller.dart';
import 'package:biadgo/logic/controller/shipment_types_controller.dart';
import 'package:biadgo/logic/controller/vehicle_category_controller.dart';
import 'package:biadgo/models/order_estimate_model.dart';
import 'package:biadgo/services/estimate_order_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EstimateOrderController extends GetxController {
  final EstimateOrderServices estimateOrderServices = EstimateOrderServices();
  final NewLocation1Controller newLocationController1 =
      Get.put(NewLocation1Controller());
  final ShipmentTypesController shipmentTypesController =
      Get.put(ShipmentTypesController());
  final VehicleCategoryController vehicleCategoryController =
      Get.put(VehicleCategoryController());
  var dataEsimate = Rxn<DataEsimate>();

  Future<void> estimateOrder(
      {required String? cargoDescription, required int cargoWeight}) async {
    try {
      final vehicleTypeId = vehicleCategoryController.selectedVehicleId.value;
      final shipmentTypeId =
          shipmentTypesController.selectedShipmentTypeId.value;
      final sourceAddress =
          newLocationController1.pickupLocationController.text;
      final sourceLat = newLocationController1.pickupLat;
      final sourceLng = newLocationController1.pickupLng;
      final destinationAddress =
          newLocationController1.dropoffLocationController.text;
      final destinationLat = newLocationController1.dropoffLat;
      final destinationLng = newLocationController1.dropoffLng;

      final result = await estimateOrderServices.estimateOrder(
        sourceAddress: sourceAddress,
        sourceLat: sourceLat,
        sourceLng: sourceLng,
        cargoDescription: cargoDescription,
        destinationAddress: destinationAddress,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
        shipmentTypeId: shipmentTypeId,
        vehicleTypeId: vehicleTypeId,
        cargoWeight: 100,
      );

      if (result != null) {
        dataEsimate.value = result;

        debugPrint("تم تحديث البيانات بنجاح");
        debugPrint("المسافة: ${result.distance}");
        debugPrint("السعر المتوقع: ${result.priceEstimated}");
        debugPrint("الوقت المتوقع: ${result.estimatedTime}");

        Get.snackbar("نجاح", "تم حساب معلومات التوصيل بنجاح",
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            icon: const Icon(Icons.check));
      } else {
        Get.snackbar("خطأ", "فشل في حساب معلومات التوصيل",
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            icon: const Icon(Icons.error));
      }
    } catch (e) {
      debugPrint("خطأ في estimateOrder: $e");
    }
  }
}
