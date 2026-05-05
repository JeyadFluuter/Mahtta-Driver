import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';

class LocationController extends GetxController {
  final Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? locationData;

  @override
  void onInit() {
    super.onInit();
    initLocationService();
  }

  Future<void> initLocationService() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    locationData = await location.getLocation();
    update();
  }

  Future<void> getCurrentLocation() async {
    try {
      final LocationData currentLoc = await location.getLocation();
      locationData = currentLoc;
      update();
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  void listenToLocationChanges() {
    location.onLocationChanged.listen((LocationData newLoc) {
      locationData = newLoc;
      update();
      debugPrint("New location: ${newLoc.latitude}, ${newLoc.longitude}");
    });
  }
}
