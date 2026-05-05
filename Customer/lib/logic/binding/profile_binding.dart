import 'package:biadgo/logic/controller/logout_controller.dart';
import 'package:biadgo/logic/controller/me_controller.dart';
import 'package:biadgo/logic/controller/profile_controller.dart';
import 'package:get/get.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => LogOutController());
    Get.lazyPut(() => MeController());
  }
}
