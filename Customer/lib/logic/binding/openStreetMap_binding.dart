import 'package:biadgo/logic/controller/confirm_order_controller.dart';
import 'package:biadgo/logic/controller/map_controller2.dart';
import 'package:get/get.dart';

class MyOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MapController2());
    Get.lazyPut(() => ConfirmOrderController());
  }
}
