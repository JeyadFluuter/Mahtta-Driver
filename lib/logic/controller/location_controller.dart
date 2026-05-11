import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import 'package:piaggio_driver/logic/controller/order_accepted_controller.dart';
import 'package:piaggio_driver/services/driver_location_services.dart';

class LocationController extends GetxController {
  final Location _location = Location();
  final DriverLocationServices _svc = DriverLocationServices();
  LocationData? currentLoc;
  StreamSubscription<LocationData>? _locationSubscription;
  late OrderAcceptedController _orderAcceptedController;
  static const int _intervalMs = 5000;
  static const double _distanceMeters = 5; // Minimum 5 meters movement
  static const LocationAccuracy _accuracy = LocationAccuracy.high;
  bool _bgConfiguredOnce = false;

  @override
  void onInit() {
    _orderAcceptedController = Get.isRegistered<OrderAcceptedController>()
        ? Get.find<OrderAcceptedController>()
        : Get.put(OrderAcceptedController(), permanent: true);
    super.onInit();
  }

  Future<void> _ensureNotificationPermission() async {
    if (GetPlatform.isAndroid) {
      final st = await ph.Permission.notification.status;
      if (!st.isGranted) {
        await ph.Permission.notification.request();
      }
    }
  }

  Future<bool> _ensureBackgroundLocationPermission() async {
    var whenInUse = await ph.Permission.location.status;
    if (!whenInUse.isGranted) {
      whenInUse = await ph.Permission.location.request();
      if (!whenInUse.isGranted) return false;
    }
    var always = await ph.Permission.locationAlways.status;
    if (!always.isGranted) {
      always = await ph.Permission.locationAlways.request();
      if (!always.isGranted) {
        await ph.openAppSettings();
        return false;
      }
    }
    return true;
  }

  Future<void> _prepareLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    await _ensureNotificationPermission();
    final okAlways = await _ensureBackgroundLocationPermission();
    if (!okAlways) return;
    if (!_bgConfiguredOnce) {
      try {
        await _location.enableBackgroundMode(enable: true);
        if (GetPlatform.isAndroid) {
          await _location.changeNotificationOptions(
            title: 'تتبع الموقع نشط',
            subtitle: 'تطبيق محطة للسائقين يعمل في الخلفية لتتبع مسار الرحلة',
            iconName: '@mipmap/ic_launcher',
            onTapBringToFront: true,
          );
        }
      } on PlatformException catch (e) {
        debugPrint('⚠️ enableBackgroundMode failed: $e');
        return;
      }
      await _location.changeSettings(
        accuracy: _accuracy,
        interval: _intervalMs,
        distanceFilter: _distanceMeters,
      );

      _bgConfiguredOnce = true;
      debugPrint('✅ Location background configured (interval=$_intervalMs ms)');
    }
  }

  Future<LocationData?> ensureLastLocation() async {
    await _prepareLocation();
    if (currentLoc == null) {
      try {
        currentLoc = await _location.getLocation();
        update();
      } catch (e) {
        debugPrint('⚠️ failed to get current location: $e');
      }
    }
    return currentLoc;
  }

  double? get lastLat => currentLoc?.latitude;
  double? get lastLng => currentLoc?.longitude;

  void startLocationTimer() async {
    if (_locationSubscription != null) return;
    await _prepareLocation();

    _locationSubscription = _location.onLocationChanged.listen((loc) async {
      try {
        currentLoc = loc;
        update();
        debugPrint('🔄 Location (Stream): ${loc.latitude}, ${loc.longitude}');

        if (_orderAcceptedController.orderId <= 0) {
          debugPrint('⚠️ تخطي إرسال الموقع: رقم الطلب غير محدد (0)');
          return;
        }

        if (loc.latitude != null && loc.longitude != null) {
          final result = await _svc.driverLocation(
            currentLat: loc.latitude!,
            currentLng: loc.longitude!,
            orderId: _orderAcceptedController.orderId,
          );
          if (result != null) {
            debugPrint('✅ تم تحديث الموقع بنجاح على الخادم: ${loc.latitude}, ${loc.longitude}');
          }
        }
      } catch (e) {
        debugPrint('❌ خطأ أثناء تحديث الموقع من الـ Stream: $e');
      }
    });

    debugPrint('✅ بدأ تتبع الموقع بنظام الـ Stream (Background Ready)');
  }

  void stopLocationTimer() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    debugPrint('🛑 تم إيقاف تتبع الموقع (Stream cancelled)');
  }

  @override
  void onClose() {
    stopLocationTimer();
    super.onClose();
  }

  Future<void> updateLocation({
    required String currentLat,
    required String currentLng,
  }) async {
    try {
      final result = await _svc.driverLocation(
        currentLat: double.parse(currentLat),
        currentLng: double.parse(currentLng),
        orderId: _orderAcceptedController.orderId,
      );
      if (result != null) {
        debugPrint('تم تحديث الموقع بنجاح: ${result.currentLat}');
      }
    } catch (e) {
      debugPrint('❌‏ $e');
    }
  }
}
