import 'package:get/get.dart';
import 'package:biadgo/logic/controller/me_controller.dart';
import 'package:biadgo/logic/controller/my_locations_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MeController());
    Get.lazyPut(() => MyLocationsController());
  }
}
