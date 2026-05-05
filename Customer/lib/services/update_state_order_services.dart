// 📁 services/order_accepted_services.dart
import 'dart:convert';
import 'dart:developer';
import 'package:biadgo/logic/controller/order_accepted_controller.dart';
import 'package:biadgo/models/order_data_model.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../constants/apiUrl.dart';

class UpdateStateOrderServices {
  UpdateStateOrderServices._();
  static final UpdateStateOrderServices _instance =
      UpdateStateOrderServices._();
  factory UpdateStateOrderServices() => _instance;
  final _pusher = PusherChannelsFlutter.getInstance();
  final _host = baseUrl;
  final _customerId = 1;
  late final OrderTrackingController trackingCtrl;

  Future<void> init() async {
    trackingCtrl = Get.isRegistered<OrderTrackingController>()
        ? Get.find()
        : Get.put(OrderTrackingController(), permanent: true);

    final GetStorage getStorage = GetStorage();
    final token = getStorage.read('token') as String?;

    await _pusher.init(
      apiKey: 'ea13bc3f077292006895',
      cluster: 'eu',
      useTLS: true,
      onAuthorizer: (channel, socketId, _) async {
        final res = await http.post(
          Uri.parse('$_host/api/broadcasting/auth'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: 'socket_id=$socketId&channel_name=$channel',
        );
        return res.statusCode == 200 ? jsonDecode(res.body) : {};
      },
    );

    await _pusher.connect();
    final channel = 'private-order.customer.$_customerId';

    await _pusher.subscribe(
      channelName: channel,
      onEvent: (e) {
        if (e.eventName == 'OrderStatusUpdated' && e.data != null) {
          try {
            final jsonData = jsonDecode(e.data!);
            final orderResponse = OrderResponse.fromJson(jsonData);
            trackingCtrl.setOrderResponse(orderResponse);
            log('✅ Order data stored successfully');
          } catch (err) {
            log('❌ Error parsing order data: \$err');
          }
        }
      },
    );
  }
}
