// ignore: file_names
import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:piaggio_driver/logic/controller/offer_notification_controller.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class NotificationService extends GetxService {
  final _pusher = PusherChannelsFlutter.getInstance();
  final _offerCtrl = Get.find<OfferNotificationController>();

  Future<NotificationService> init() async {
    await _pusher.init(
      apiKey: 'a34cc71b9ff9fafec6a8',
      cluster: 'mt1',
      onConnectionStateChange: (cur, prev) => log('Pusher: $cur (was $prev)'),
      onError: (msg, code, err) => log('PusherError: $msg code:$code $err'),
    );
    await _pusher.connect();
    await _pusher.subscribe(
      channelName: 'name_channell',
      onEvent: (event) {
        if (event.eventName == 'name_eventt' && event.data != null) {
          String msg;
          try {
            final body = jsonDecode(event.data!);
            msg = body['message'] ?? body.toString();
          } catch (_) {
            msg = event.data!;
          }
          _offerCtrl.addNotification(msg);
          log('Notif added: $msg');
        }
      },
    );
    return this;
  }

  @override
  void onClose() {
    _pusher.disconnect();
    super.onClose();
  }
}
