// imports أعلى الملف
import 'package:biadgo/models/order_data_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderTrackingController extends GetxController {
  final Rxn<OrderResponse> orderResponse = Rxn<OrderResponse>();
  final Rxn<bool> isLoading = Rxn<bool>();

  LatLng? lastValidFrom, lastValidTo;
  LatLng? _lastValidDriverFromSnapshot;

  final Rxn<LatLng> driverLivePos = Rxn<LatLng>();

  void setLiveDriver(double lat, double lng) {
    driverLivePos.value = LatLng(lat, lng);
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    return double.tryParse(v.toString());
  }

  bool _isValid(dynamic v) {
    if (v == null) return false;
    final s = v.toString().trim().toLowerCase();
    return s.isNotEmpty && s != 'null' && s != '0' && s != '0.0';
  }

  void setOrderResponse(OrderResponse resp) {
    try {
      if (_isValid(resp.order.fromLat) && _isValid(resp.order.fromLng)) {
        final lat = _toDouble(resp.order.fromLat);
        final lng = _toDouble(resp.order.fromLng);
        if (lat != null && lng != null) lastValidFrom = LatLng(lat, lng);
      }
      if (_isValid(resp.order.toLat) && _isValid(resp.order.toLng)) {
        final lat = _toDouble(resp.order.toLat);
        final lng = _toDouble(resp.order.toLng);
        if (lat != null && lng != null) lastValidTo = LatLng(lat, lng);
      }
      if (_isValid(resp.order.driver.currentLat) &&
          _isValid(resp.order.driver.currentLng)) {
        final lat = _toDouble(resp.order.driver.currentLat);
        final lng = _toDouble(resp.order.driver.currentLng);
        print('📍 Tracking: Driver Lat/Lng from object: $lat, $lng');
        if (lat != null && lng != null) {
          _lastValidDriverFromSnapshot = LatLng(lat, lng);
          driverLivePos.value = LatLng(lat, lng);
        }
      } else {
        final dynamic raw = resp.order;
        final fallbackLat = raw.currentLat ?? raw.lat ?? raw.latitude;
        final fallbackLng = raw.currentLng ?? raw.lng ?? raw.longitude;
        print('📍 Tracking: Driver data missing in driver object. Fallback: $fallbackLat, $fallbackLng');

        if (_isValid(fallbackLat) && _isValid(fallbackLng)) {
          final lat = _toDouble(fallbackLat);
          final lng = _toDouble(fallbackLng);
          print('📍 Tracking: Using fallback Lat/Lng: $lat, $lng');
          if (lat != null && lng != null) {
            _lastValidDriverFromSnapshot = LatLng(lat, lng);
            driverLivePos.value = LatLng(lat, lng);
          }
        }
      }
      orderResponse.value = resp;
      update();
    } catch (e) {
      print('🚨 Tracking Error in setOrderResponse: $e');
    }
  }

  LatLng? get lastValidDriver =>
      driverLivePos.value ?? _lastValidDriverFromSnapshot;
}
