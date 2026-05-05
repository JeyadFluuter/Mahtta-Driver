import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../constants/api_Url.dart';
import '../logic/controller/location_controller.dart';
import '../logic/controller/me_controller.dart';
import '../logic/controller/order_tracking_controller.dart';
import '../model/order_data_model.dart';
import '../logic/controller/order_accepted_controller.dart';

class OrderAcceptedServices {
  OrderAcceptedServices._();
  static final OrderAcceptedServices _i = OrderAcceptedServices._();
  factory OrderAcceptedServices() => _i;
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  final String _host = baseUrl;
  final MeController _meCtrl = Get.put(MeController());
  late OrderTrackingController _trackingCtrl;
  int? _driverId;
  bool _pusherReady = false;
  bool _subscribed = false;
  bool initialised = false;

  Future<void> init([int? orderId]) async {
    try {
      _driverId ??= int.tryParse(_meCtrl.id.value);
      _prepareTrackingController();
      if (orderId != null) {
        Get.find<OrderAcceptedController>().setOrderId(orderId);
        await _refreshSnapshot(orderId);
      }
      if (!_pusherReady) await _preparePusher();
      if (!_subscribed) await _subscribeDriverChannel();
      Get.find<LocationController>().startLocationTimer();
      initialised = true;
    } catch (e, s) {
      log('💥 OrderAcceptedServices.init error → $e', stackTrace: s);
    }
  }

  Future<void> dispose() async {
    if (_subscribed && _driverId != null) {
      await _pusher.unsubscribe(
          channelName: 'private-order.driver.${_driverId!}');
      _subscribed = false;
    }
    await _pusher.disconnect();
    _pusherReady = false;
    Get.find<LocationController>().stopLocationTimer();
    initialised = false;
  }

  void _prepareTrackingController() {
    if (!Get.isRegistered<OrderTrackingController>()) {
      Get.put(OrderTrackingController(), permanent: true);
    }
    _trackingCtrl = Get.find<OrderTrackingController>();
  }

  Future<void> _refreshSnapshot(int orderId) async {
    try {
      final snap = await _getTracking(orderId);
      _trackingCtrl.setOrderResponse(snap);
    } on Exception catch (e) {
      if (!e.toString().contains('not-found')) rethrow;
      log('ℹ️ order $orderId غير متاح حالياً – ننتظر Pusher');
    }
  }

  Future<void> _preparePusher() async {
    final token = GetStorage().read('token');

    await _pusher.init(
      apiKey: PUSHER_APP_KEY,
      cluster: PUSHER_APP_CLUSTER,
      useTLS: true,
      onAuthorizer: (ch, socketId, _) async {
        final res = await http.post(
          Uri.parse(pusherAuthBaseUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: 'socket_id=$socketId&channel_name=$ch',
        );
        return res.statusCode == 200 ? jsonDecode(res.body) : {};
      },
      onConnectionStateChange: (cur, prev) =>
          log('🔄 Pusher: $prev ➜ $cur ($_driverId)'),
      onError: (msg, code, err) => log('❌ Pusher error [$code] $msg – $err'),
    );

    await _pusher.connect();
    _pusherReady = true;
  }

  Future<void> _subscribeDriverChannel() async {
    if (_driverId == null) return;
    final ch = 'private-order.driver.${_driverId!}';

    await _pusher.subscribe(
      channelName: ch,
      onSubscriptionSucceeded: (_) {
        log('✅ subscribed $ch');

        Get.find<LocationController>().startLocationTimer();
        debugPrint("بدأ تتبع السائق");
      },
      onEvent: (event) {
        if (event is PusherEvent) _handleEvent(event);
      },
    );

    _subscribed = true;
  }

  Future<OrderResponse> _getTracking(int orderId) async {
    final token = GetStorage().read('token');
    final res = await http.get(
      Uri.parse('$apiUrl/orders/order/$orderId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    log('📦 RAW REST body: ${res.body}');

    if (res.statusCode == 200) {
      return OrderResponse.fromJson(jsonDecode(res.body)['data']);
    }
    if (res.statusCode == 404) throw Exception('not-found');
    throw Exception('getTracking failed → ${res.statusCode}');
  }

  void _handleEvent(PusherEvent e) {
    if (e.eventName != 'OrderAccepted' || e.data == null) return;
    try {
      final js = jsonDecode(e.data!);
      final status = Status.fromJson(js['order']['status']);

      _trackingCtrl.updateStatus(status);
      _trackingCtrl.setOrderResponse(OrderResponse.fromJson(js));

      debugPrint('📦 طلب جديد $js');

      if (status.id == 6) Get.find<LocationController>().stopLocationTimer();
    } catch (err) {
      log('❌ JSON parse error → $err');
    }
  }
}
