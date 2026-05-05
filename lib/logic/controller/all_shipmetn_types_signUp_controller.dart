import 'package:get/get.dart';
import 'package:piaggio_driver/model/all_shipment_types_signUp_model.dart';
import 'package:piaggio_driver/services/all_shipment_type_services.dart';

class AllShipmentTypesSignupController extends GetxController {
  final types = <AllShipmentTypesSignupModel>[].obs;
  final selected = <AllShipmentTypesSignupModel>[].obs;

  final isLoading = true.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    try {
      isLoading.value = true;
      types.assignAll(await AllShipmentTypeServices().fetchAll());
    } catch (_) {
      error.value = 'تعذّر تحميل الأنواع';
    } finally {
      isLoading.value = false;
    }
  }

  void toggle(AllShipmentTypesSignupModel m) {
    final idx = selected.indexWhere((e) => e.id == m.id);
    if (idx >= 0) {
      selected.removeAt(idx);
    } else {
      selected.add(m);
    }
    selected.refresh();
  }

  List<int> get selectedIds => selected.map((e) => e.id).toList();
  Map<String, dynamic> get bodyForApi => {'shipment_type_ids': selectedIds};
}
