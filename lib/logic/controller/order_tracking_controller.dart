import 'package:get/get.dart';
import 'package:piaggio_driver/model/order_data_model.dart';

class OrderTrackingController extends GetxController {
  final Rxn<OrderResponse> orderResponse = Rxn<OrderResponse>();
  final Rxn<Status> currentStatus = Rxn<Status>();

  void setOrderResponse(OrderResponse resp) {
    orderResponse.value = resp;
    currentStatus.value = resp.status;
  }

  void updateStatus(Status newStatus) {
    currentStatus.value = newStatus;
    if (orderResponse.value != null) {
      orderResponse.value = orderResponse.value!.copyWith(status: newStatus);
    }
  }
}
