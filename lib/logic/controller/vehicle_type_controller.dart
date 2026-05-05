import 'package:get/get.dart';
import 'package:piaggio_driver/model/vehicle_type_model.dart';
import 'package:piaggio_driver/services/vehicle_type_services.dart';

class VehicleCategoryController extends GetxController {
  final RxList<VehicleCategory> categories = <VehicleCategory>[].obs;

  RxInt selectedCategoryId = 0.obs;
  RxInt selectedVehicleId = 0.obs;

  final isLoading = false.obs;
  final _service = VehicleCategoryService();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
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
