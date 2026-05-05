import 'package:get/get.dart';
import 'package:piaggio_driver/logic/controller/driver_active_controller.dart';
import 'package:piaggio_driver/logic/controller/me_controller.dart';

class StatusController extends GetxController {
  final RxBool isActivated = false.obs;
  late final MeController _me;
  final DriverActiveController _driverActive =
      Get.put(DriverActiveController());

  @override
  void onInit() {
    super.onInit();
    _me = Get.find<MeController>();
    isActivated.value = _stringToBool(_me.isActive.value);
  }

  Future<void> toggleActivation() async {
    if (!isActivated.value) {
      isActivated.value = true;
      _me.isActive.value = '1';

      try {
        final success = await _driverActive.updateActiveStatus(isOnline: true);
        if (!success) {
          isActivated.value = false;
          _me.isActive.value = '0';
        }
      } catch (e) {
        isActivated.value = false;
        _me.isActive.value = '0';
        rethrow;
      }
    } else {
      isActivated.value = false;
      _me.isActive.value = '0';
      await _driverActive.updateActiveStatus(isOnline: false);
    }
  }

  bool _stringToBool(String s) {
    return s == '1' || s.toLowerCase() == 'true';
  }
}
