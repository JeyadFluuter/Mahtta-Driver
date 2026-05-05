import 'package:get/get.dart';
import 'package:piaggio_driver/model/shipment_type_model.dart';
import 'package:piaggio_driver/services/my_shipmeny_type_services.dart';

class MyShipmentTypeController extends GetxController {
  final RxList<ShipmentTypeModel> types = <ShipmentTypeModel>[].obs;
  final RxList<ShipmentTypeModel> selected = <ShipmentTypeModel>[].obs;
  final isLoading = true.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchTypes();
  }

  Future<void> _fetchTypes() async {
    try {
      isLoading(true);

      final data = await MyShipmenyTypeServices().myShipmentTypesData();
      types.assignAll(data);
      selected.assignAll(data.where((e) => e.isSelected).toList());
    } catch (_) {
      error.value = 'تعذّر تحميل أنواع الشحن';
    } finally {
      isLoading(false);
    }
  }

  void toggle(ShipmentTypeModel t) {
    final idx = selected.indexWhere((e) => e.id == t.id);
    if (idx >= 0) {
      selected.removeAt(idx);
    } else {
      selected.add(t);
    }
    selected.refresh();
  }

  void clear() => selected.clear();

  List<int> get selectedIds => selected.map((e) => e.id).toList();
  Map<String, dynamic> get bodyForApi => {'shipment_type_ids': selectedIds};
}
