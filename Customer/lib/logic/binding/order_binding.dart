import 'package:biadgo/logic/controller/confirm_order_controller.dart';
import 'package:get/get.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => MapController());
    Get.lazyPut(() => ConfirmOrderController());
  }
}
