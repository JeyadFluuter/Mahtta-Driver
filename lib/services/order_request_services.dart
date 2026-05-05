import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:piaggio_driver/constants/api_Url.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/logic/controller/order_accepted_controller.dart';
import 'package:piaggio_driver/logic/controller/order_request_controller.dart';
import 'package:piaggio_driver/model/order_request_model.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherService extends GetxService with WidgetsBindingObserver {
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  final String _host = baseUrl;

  bool _ready = false;
  bool _subscribed = false;
  String? _currentChannel;
  final OrderController _orderCtrl = Get.find<OrderController>();
  OrderAcceptedController get _acceptedCtrl =>
      Get.isRegistered<OrderAcceptedController>()
          ? Get.find<OrderAcceptedController>()
          : Get.put(OrderAcceptedController(), permanent: true);
  int get _driverId {
    final raw = GetStorage().read('id');
    return raw is int ? raw : (raw is String ? int.tryParse(raw) ?? 0 : 0);
  }

  String get _token => GetStorage().read<String>('token') ?? '';
  String get _channelName => 'private-order.notification.$_driverId';
  bool get needsAuth => _token.isEmpty || _driverId <= 0;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ensureConnected();
    }
  }

  Future<void> ensureBoot() async {
    if (needsAuth) return;
    await ensureConnected();
  }

  Future<void> ensureConnected({bool forceResubscribe = false}) async {
    if (!_ready) {
      final ok = await _safeInit();
      if (!ok) return;
    }

    if (_pusher.connectionState == 'CONNECTED') {
      if (forceResubscribe || !_subscribed || _currentChannel != _channelName) {
        await _subscribeSafe();
      }
    } else {
      await _pusher.connect();
      await _subscribeSafe();
    }
  }

  Future<bool> _safeInit() async {
    if (needsAuth) return false;

    await _pusher.init(
      apiKey: PUSHER_APP_KEY,
      cluster: PUSHER_APP_CLUSTER,
      useTLS: true,
      onAuthorizer: (channel, socketId, _) async {
        final res = await http.post(
          Uri.parse(pusherAuthBaseUrl),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token',
          },
          body: 'socket_id=$socketId&channel_name=$channel',
        );
        log('🔐 Auth ${res.statusCode}  channel=$channel');
        return res.statusCode == 200 ? jsonDecode(res.body) : {};
      },
      onConnectionStateChange: (cur, prev) {
        log('🔄 Pusher: $prev ➜ $cur ($_driverId)');
        if (cur != 'CONNECTED') {
          _subscribed = false;
        }
      },
      onError: (msg, code, err) => log('❌ Pusher error [$code] $msg – $err'),
    );

    await _pusher.connect();
    _ready = true;
    return true;
  }

  Future<void> _subscribeSafe() async {
    if (needsAuth) return;

    if (_currentChannel != null && _currentChannel != _channelName) {
      try {
        await _pusher.unsubscribe(channelName: _currentChannel!);
      } catch (_) {}
      _subscribed = false;
      _currentChannel = null;
    }

    try {
      await _pusher.unsubscribe(channelName: _channelName);
    } catch (_) {}

    await _pusher.subscribe(
      channelName: _channelName,
      onSubscriptionSucceeded: (_) {
        _subscribed = true;
        _currentChannel = _channelName;
        log('✅ Subscribed to $_channelName (driverId=$_driverId)');
      },
      onEvent: (e) {
        try {
          if (e.eventName != 'OrderNotificationSent' || e.data == null) {
            log('📨 Pusher event: ${e.eventName} | no-data? ${e.data == null}');
            return;
          }

          log('📨 raw data: ${e.data}');
          final decoded = jsonDecode(e.data!);
          final dynamic orderJsonDyn =
              decoded['order_data'] ?? decoded['order'];
          if (orderJsonDyn == null || orderJsonDyn is! Map) {
            log('⚠️ Unexpected payload shape');
            return;
          }

          final orderJson = Map<String, dynamic>.from(orderJsonDyn);
          final orderData = OrderData.fromJson(orderJson);
          GetStorage().write('latest_order_id', orderData.id);
          _orderCtrl.setCurrentOrder(orderData);
          _acceptedCtrl.setOrderId(orderData.id);

          log('📦 طلب جديد #${orderData.id} وصل من Pusher ✅');
        } catch (err, st) {
          log('❌ JSON parse/handle error: $err\n$st');
        }
      },
    );
  }

  Future<void> reconnectWithNewToken() async {
    try {
      if (_currentChannel != null) {
        await _pusher.unsubscribe(channelName: _currentChannel!);
      }
    } catch (_) {}
    try {
      await _pusher.disconnect();
    } catch (_) {}

    _ready = false;
    _subscribed = false;
    _currentChannel = null;

    await ensureConnected();
  }

  Future<void> disconnect() async {
    try {
      if (_currentChannel != null) {
        await _pusher.unsubscribe(channelName: _currentChannel!);
      }
      await _pusher.disconnect();
    } catch (e) {
      log('❌ Error during disconnect: $e');
    } finally {
      _ready = false;
      _subscribed = false;
      _currentChannel = null;
      log('🔌 Pusher disconnected');
    }
  }
}
