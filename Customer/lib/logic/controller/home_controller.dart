import 'dart:async';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'me_controller.dart';
import 'my_locations_controller.dart';

class HomeController extends GetxController {
  final MeController meController = Get.find();
  final MyLocationsController locations = Get.put(MyLocationsController());

  final isConnected = true.obs;
  final showConnectedBar = false.obs;
  final isLoading = false.obs;

  bool _firstEventHandled = false;
  Timer? _greenTimer;
  StreamSubscription<InternetStatus>? _sub;

  @override
  void onInit() {
    super.onInit();
    refreshAll();
    _sub = InternetConnection().onStatusChange.listen((status) {
      final nowConnected = status == InternetStatus.connected;

      if (_firstEventHandled) {
        if (!isConnected.value && nowConnected) {
          _greenTimer?.cancel();
          showConnectedBar.value = true;

          _greenTimer = Timer(const Duration(seconds: 4), () {
            showConnectedBar.value = false;
          });
        }
      } else {
        _firstEventHandled = true;
      }

      isConnected.value = nowConnected;
    });
  }

  Future<void> refreshAll() async {
    try {
      isLoading.value = true;
      await Future.wait([
        meController.meUser(),
        locations.loadAllForDropdown(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    _greenTimer?.cancel();
    super.onClose();
  }
}
