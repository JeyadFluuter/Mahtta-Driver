import 'package:get/get.dart';

class OfferNotificationController extends GetxController {
  final notifications = <String>[].obs;
  final unreadCount = 0.obs;
  void addNotification(String msg) {
    notifications.add(msg);
    unreadCount.value++;
  }

  void markRead() {
    unreadCount.value = 0;
  }
}
