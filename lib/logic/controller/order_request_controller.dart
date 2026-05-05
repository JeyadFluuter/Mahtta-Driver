import 'package:get/get.dart';
import 'package:piaggio_driver/model/order_request_model.dart';

class OrderController extends GetxController {
  final Rx<OrderData?> currentOrder = Rx<OrderData?>(null);

  void setCurrentOrder(OrderData order) {
    currentOrder.value = order;
  }

  void clearCurrentOrder() {
    currentOrder.value = null;
  }
}
