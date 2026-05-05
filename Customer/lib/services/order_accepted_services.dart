import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:biadgo/constants/apiUrl.dart';
import 'package:biadgo/logic/controller/me_controller.dart';
import 'package:biadgo/logic/controller/order_accepted_controller.dart';
import 'package:biadgo/models/order_data_model.dart';
import 'package:biadgo/logic/controller/confirm_order_controller.dart';
import 'package:biadgo/routes/routes.dart';
import 'package:biadgo/models/my_order_model.dart';
import 'package:biadgo/logic/controller/my_order_controller.dart';
import 'package:biadgo/views/traceking_order_screen.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class OrderAcceptedServices {
  OrderAcceptedServices._();
  static final OrderAcceptedServices _instance = OrderAcceptedServices._();
  factory OrderAcceptedServices() => _instance;
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  static const String _apiKey = 'ea13bc3f077292006895';
  static const String _cluster = 'eu';
  final String _host = baseUrl;

  final MeController _meCtrl = Get.put(MeController());
  late OrderTrackingController _trackingCtrl;
  late int _customerId;
  late int orderId;
  bool _initialized = false;
  bool _pusherReady = false;
  bool _subscribed = false;
  DateTime? _lastFetchAt;
  int? _lastFetchedOid;
  int? _latestOid;
  int? get latestOid => _latestOid;
  bool _isScreenOpen = false;
  int? _screenOrderId;
  final Set<int> _dismissedOrders = {};
  Worker? _backupWorker;

  void markScreenOpened(int orderId) {
    _isScreenOpen = true;
    _screenOrderId = orderId;
    _dismissedOrders.remove(orderId);
    log('🟢 tracking screen OPENED for #$orderId');
  }

  void markScreenClosed(int orderId, {bool dismissed = true}) {
    if (_screenOrderId == orderId) {
      _isScreenOpen = false;
      _screenOrderId = null;
    }
    if (dismissed) _dismissedOrders.add(orderId);
    log('🔴 tracking screen CLOSED for #$orderId (dismissed=$dismissed)');
  }

  bool _canAutoOpen(int orderId) =>
      !_isScreenOpen && !_dismissedOrders.contains(orderId);

  // ======================================================

  Future<OrderResponse> getTracking(int orderId) async {
    final GetStorage getStorage = GetStorage();
    final token = getStorage.read('token') as String?;

    log('🔄 Fetch order $orderId');

    final res = await http.get(
      Uri.parse('$apiUrl/orders/order/$orderId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      print('📡 API Tracking Response: ${res.statusCode} - ${res.body.substring(0, res.body.length > 200 ? 200 : res.body.length)}');
      return OrderResponse.fromJson(jsonDecode(res.body)['data']);
    }
    throw Exception('خطأ في جلب بيانات التتبع (${res.statusCode})');
  }

  Future<void> init(int orderId) async {
    log('▶️ init($orderId)');
    if (_initialized) await dispose(keepConnection: true);
    _initialized = true;
    this.orderId = orderId;
    await _bootstrapCustomer();
    _prepareTrackingController();
    await _ensurePusherReady();
    await _ensureSubscribed();
    final snap = await getTracking(orderId);
    _trackingCtrl.setOrderResponse(snap);
  }

  Future<void> listenForNextAccepted() async {
    log('▶️ listenForNextAccepted()');
    if (_initialized) await dispose(keepConnection: true);
    _initialized = true;

    await _bootstrapCustomer();
    _prepareTrackingController();

    _isScreenOpen = false;
    _dismissedOrders.clear();
    _isScreenOpen = false;
    _dismissedOrders.clear();
    await _ensurePusherReady();
    await _ensureSubscribed();
    _startBackupWorker();
  }

  void _startBackupWorker() {
    _backupWorker?.dispose();
    if (!Get.isRegistered<MyOrderController>()) {
      log('⚠️ BackupWorker: MyOrderController not registered yet. Skipping.');
      return;
    }
    _backupWorker = ever<MyOrder?>(Get.find<MyOrderController>().latestActiveOrder, (order) {
      if (order != null && order.id != 0) {
        final status = order.status?.name ?? '';
        // إذا كان الطلب في حالة نشطة وليست "قيد الانتظار" فهذا يعني أنه تم قبوله
        if (status != 'قيد الانتظار' && status != 'Pending' && _isOngoingStatus(status)) {
          log('🔄 Backup: Auto-navigating to accepted order #${order.id} (Status: $status)');
          _navigateToTracking(order.id!);
        }
      }
    });
  }

  bool _isOngoingStatus(String? s) {
    if (s == null || s.isEmpty) return false;
    const terminalStatuses = {
      'تم التوصيل', 'ملغية', 'ملغية (قبل القبول)', 'ملغية (بعد القبول)',
      'مرفوضة', 'مكتملة', 'تم الالغاء', 'تم الإلغاء', 'Cancelled', 'Delivered',
    };
    return !terminalStatuses.contains(s);
  }

  Future<void> _bootstrapCustomer() async {
    int attempts = 0;
    while (_meCtrl.id.value.isEmpty && attempts < 50) { // حد أقصى 5 ثوانٍ
      if (attempts == 0) _meCtrl.meUser(); // محاولة جلب البيانات إذا كانت ناقصة
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    
    if (_meCtrl.id.value.isEmpty) {
      throw Exception('تعذر جلب بيانات المستخدم (User ID is missing)');
    }
    _customerId = int.parse(_meCtrl.id.value);
  }

  void _prepareTrackingController() {
    if (!Get.isRegistered<OrderTrackingController>(tag: 'tracking')) {
      Get.put(OrderTrackingController(), tag: 'tracking');
    }
    _trackingCtrl = Get.find<OrderTrackingController>(tag: 'tracking');
  }

  Future<void> _ensurePusherReady() async {
    if (_pusherReady) return;

    await _pusher.init(
      apiKey: _apiKey,
      cluster: _cluster,
      useTLS: true,
      onAuthorizer: (ch, socketId, _) async {
        final GetStorage getStorage = GetStorage();
        final token = getStorage.read('token') as String?;

        if (token == null) return null;
        final resp = await http.post(
          Uri.parse('$_host/api/broadcasting/auth'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
          },
          body: 'socket_id=$socketId&channel_name=$ch',
        );
        log('🔐 Auth ${resp.statusCode} channel=$ch body=${resp.body}');
        if (resp.statusCode != 200) return null;
        final data = jsonDecode(resp.body);
        if (data is Map && data['auth'] != null) {
          return Map<String, dynamic>.from(data);
        }
        return null;
      },
      onConnectionStateChange: (cur, prev) {
        log('🔄 Pusher: $prev ➜ $cur ($_customerId)');
        if (cur == 'CONNECTED') {
          _renew();
        }
      },
      onError: (msg, code, err) => log('❌ Pusher error [$code] $msg – $err'),
    );

    await _pusher.connect();
    _pusherReady = true;
  }

  Future<void> _ensureSubscribed() async {
    final ch = 'private-order.customer.$_customerId';

    if (_subscribed) {
      try {
        await _pusher.unsubscribe(channelName: ch);
      } catch (_) {}
      _subscribed = false;
    }

    await _pusher.subscribe(
      channelName: ch,
      onSubscriptionSucceeded: (_) {
        _subscribed = true;
        log('✅ subscribed $ch');
      },
      onEvent: (e) {
        if (e is PusherEvent) _handleEvent(e);
      },
    );
  }

  Future<void> _renew() async {
    final ch = 'private-order.customer.$_customerId';
    try {
      await _pusher.unsubscribe(channelName: ch);
    } catch (_) {}
    _subscribed = false;
    await _ensureSubscribed();
  }

  void _handleEvent(PusherEvent e) async {
    log('🔔 Pusher Event Received: ${e.eventName}');
    if ((e.eventName != 'OrderAccepted' && e.eventName != 'OrderStatusUpdated') || e.data == null) return;

    final data = jsonDecode(e.data!);

    final loc = data['driver_location'] as Map<String, dynamic>?;
    if (loc != null) {
      final lat = (loc['lat'] as num?)?.toDouble();
      final lng = (loc['lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        try {
          _trackingCtrl.setLiveDriver(lat, lng);
        } catch (_) {}
        log('📍 DriverLocationUpdate → lat=$lat, lng=$lng');
      }
    }

    final oid = data['order']['id'] as int;
    log('📢 OrderAccepted → $oid');
    
    // محاولة جلب البيانات الجديدة وتحديث وحدة التحكم MyOrderController
    try {
      final fresh = await getTracking(oid);
      _trackingCtrl.setOrderResponse(fresh);
      _updateMyOrderController(fresh.order);

      // إذا كانت الحالة ملغية (7 أو 8)، ننتظر قليلاً ثم نغلق شاشة التتبع
      if (fresh.order.status.id == 7 || fresh.order.status.id == 8) {
        log('⚠️ Order #$oid was CANCELLED (Status: ${fresh.order.status.id}). Closing tracking.');
        Future.delayed(const Duration(seconds: 3), () {
          if (Get.currentRoute.contains('tracekingOrderScreen') || _isScreenOpen) {
            Get.offAllNamed(AppRoutes.navbar);
          }
        });
        return; // لا ننتقل إلى شاشة التتبع إذا كانت ملغية أصلاً، أو إذا انتقلنا بالفعل فسيتم الإغلاق بعد 3 ثوانٍ
      }
    } catch (err) {
      log('❌ getTracking error: $err');
    }

    _navigateToTracking(oid);
  }

  void _navigateToTracking(int oid) {
    final canOpen = _canAutoOpen(oid);
    log('🧐 _canAutoOpen(#$oid) -> $canOpen (isScreenOpen=$_isScreenOpen, dismissed=${_dismissedOrders.contains(oid)})');

    if (canOpen) {
      log('🧭 navigate to tracking screen for #$oid');
      _latestOid = oid;
      
      final go = () => TracekingOrderScreen(orderId: oid);
      Get.find<ConfirmOrderController>().clearSearchSession();
      
      // نستخدم Get.offAll للانتقال مباشرة إلى شاشة التتبع ومسح أي شاشات أخرى (مثل شاشة البحث)
      // هذا يضمن اختفاء واجهة التوقيت فوراً واستبدالها بواجهة التتبع لضمان أفضل تجربة للمستخدم.
      Get.offAll(go);
    } else {
      log('🚫 skip navigation (screenOpen=$_isScreenOpen, dismissed=${_dismissedOrders.contains(oid)})');
    }
  }

  void _updateMyOrderController(Order o) {
    if (Get.isRegistered<MyOrderController>()) {
      final myOrderCtrl = Get.find<MyOrderController>();
      final updatedOrder = MyOrder(
        id: o.id,
        customerId: o.customerId,
        driverId: o.driverId,
        vehicleTypeId: o.vehicleTypeId,
        shipmentTypeId: o.shipmentTypeId,
        shipmentTypeName: o.shipmentTypeName,
        fromAddress: o.fromAddress,
        fromLat: o.fromLat,
        fromLng: o.fromLng,
        toAddress: o.toAddress,
        toLat: o.toLat,
        toLng: o.toLng,
        distanceEstimated: o.distanceEstimated,
        priceEstimated: double.tryParse(o.priceEstimated),
        description: o.description,
        cargoWeight: double.tryParse(o.cargoWeight ?? '0'),
        paymentMethod: o.paymentMethod,
        status: OrderStatus(
          id: o.status.id,
          name: o.status.name,
          description: o.status.description,
          driverStatus: o.status.driverStatus,
          icon: o.status.icon,
        ),
        createdAt: o.createdAt,
        updatedAt: o.updatedAt,
      );
      myOrderCtrl.latestActiveOrder.value = updatedOrder;
      myOrderCtrl.hasAcceptedOrder.value = true;
    }
  }

  Future<void> dispose({bool keepConnection = true}) async {
    try {
      if (_subscribed) {
        final ch = 'private-order.customer.$_customerId';
        await _pusher.unsubscribe(channelName: ch);
      }
    } catch (_) {}
    _subscribed = false;

    if (!keepConnection && _pusherReady) {
      try {
        await _pusher.disconnect();
      } catch (_) {}
      _pusherReady = false;
    }

    _initialized = false;
  }
}
