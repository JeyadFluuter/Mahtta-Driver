import 'package:biadgo/logic/controller/map_controller2.dart';
import 'package:biadgo/models/vehicle_types_model.dart';
import 'package:biadgo/services/vehicle_category_service.dart';
import 'package:get/get.dart';
import '../../logic/controller/shipment_types_controller.dart';
class VehicleCategoryController extends GetxController {
  final RxList<VehicleCategory> categories = <VehicleCategory>[].obs;
  RxInt selectedCategoryId = 0.obs;
  RxInt selectedVehicleId = 0.obs;
  final isLoading = false.obs;
  final _service = VehicleCategoryService();

  @override
  void onInit() {
    super.onInit();

    // نراقب تغيير نوع البضاعة لإعادة تحميل الفئات
    final stCtrl = Get.put(ShipmentTypesController());
    ever(stCtrl.selectedShipmentTypeId, (id) {
      if (id > 0) {
        fetchCategories();
      }
    });

    // عند تغيير نوع البضاعة تتحدث الأسعار - نعيد ضبط الاختيار إذا أصبح غير متاح
    ever(Get.put(MapController2()).vehiclePrices, (_) {
      final mapCtrl = Get.find<MapController2>();
      final currentCatId = selectedCategoryId.value;
      if (currentCatId != 0) {
        final cat = categories.firstWhereOrNull((c) => c.id == currentCatId);
        if (cat != null && !mapCtrl.categoryHasAvailableVehicle(cat)) {
          selectedCategoryId(0);
          selectedVehicleId(0);
        }
      }
    });
  }

  Future<void> fetchCategories() async {
    try {
      isLoading(true);
      categories.assignAll(await _service.fetchVehicleCategories());
    } finally {
      isLoading(false);
    }
  }

  void selectCategory(int id) => selectedCategoryId(id);
  void selectVehicle(int id) => selectedVehicleId(id);

  List<Vehicle> getVehiclesForSelectedCategory() {
    final cat =
        categories.firstWhereOrNull((c) => c.id == selectedCategoryId.value);
    return cat?.vehicles ?? [];
  }
}
