import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:piaggio_driver/logic/controller/location_controller.dart';
import 'package:piaggio_driver/logic/controller/offer_notification_controller.dart';
import 'package:piaggio_driver/logic/controller/order_request_controller.dart';
import 'package:piaggio_driver/services/order_request_services.dart';

class AppServices extends GetxService {
  final GetStorage box = GetStorage();

  Future<AppServices> init() async {
    Get.put(LocationController(), permanent: true);
    Get.put(OfferNotificationController(), permanent: true);
    Get.put(OrderController(), permanent: true);
    Get.put<PusherService>(PusherService(), permanent: true);
    await Get.find<PusherService>().ensureBoot();
   

    return this;
  }
}

