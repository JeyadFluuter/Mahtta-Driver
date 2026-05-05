import 'package:biadgo/logic/controller/my_order_controller.dart';
import 'package:get/get.dart';

class MyOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MyOrderController());
  }
}
