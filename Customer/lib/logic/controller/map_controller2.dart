import 'dart:async';
import 'dart:convert';

import 'package:biadgo/constants/apiUrl.dart';
import 'package:biadgo/logic/controller/shipment_types_controller.dart';
import 'package:biadgo/models/shipment_types_model.dart';
import 'package:biadgo/models/vehicle_types_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

class MapController2 extends GetxController {
  final List<LatLng> savedFirstLocations = const [
    LatLng(32.8841, 13.1852),
    LatLng(32.8950, 13.1800),
  ];

  final List<LatLng> savedSecondLocations = const [
    LatLng(32.8900, 13.1900),
    LatLng(32.9000, 13.2000),
  ];

  final Rx<LatLng?> firstLocation = Rx<LatLng?>(null);
  final Rx<LatLng?> secondLocation = Rx<LatLng?>(null);

  final RxString firstAddress = "".obs;
  final RxString secondAddress = "".obs;
  final RxString firstLocality = "".obs;
  final RxString secondLocality = "".obs;
  final RxBool addressLoading = false.obs;

  final RxList<dynamic> vehiclePrices = <dynamic>[].obs;
  final RxBool priceLoading = false.obs;
  final RxString estimateError = "".obs;

  // 0: None, 1: First Point, 2: Second Point
  final RxInt pickingMode = 0.obs;

  final nameSourceController = TextEditingController();
  final nameDestinationController = TextEditingController();

  final pickupLatController = TextEditingController();
  final pickupLngController = TextEditingController();
  final dropoffLatController = TextEditingController();
  final dropoffLngController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    final stCtrl = Get.put(ShipmentTypesController());

    ever<int?>(stCtrl.selectedShipmentTypeId, (id) {
      final type = stCtrl.shipmentTypes.firstWhereOrNull((t) => t.id == id);
      if (_shouldCalculate(type)) {
        // بدون await باش ما يوقفش UI
        calculateDeliveryInfo();
      }
    });
  }

  bool categoryHasAvailableVehicle(VehicleCategory cat) {
    if (vehiclePrices.isEmpty) return false;
    // السيرفر قد يُرجع vehicle_type_id كـ String أو int
    final idsWithPrice = vehiclePrices
        .map((e) => int.tryParse(e['vehicle_type_id'].toString()) ?? -1)
        .toSet();
    return cat.vehicles.any((v) => idsWithPrice.contains(v.id));
  }

  // ✅ Reverse واحد فقط يرجّع address + locality في طلب واحد
  Future<Map<String, String>> reverseOnce(LatLng pos) async {
    try {
      final url = Uri.parse(
        "https://nominatim.openstreetmap.org/reverse"
        "?lat=${pos.latitude}&lon=${pos.longitude}&format=jsonv2",
      );

      final res = await http.get(
        url,
        headers: {
          // مهم لنوميناتيم
          'User-Agent': 'com.example.biadgo',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15)); // زيادة المهلة لتجنب فشل الجلب في الشبكات الضعيفة

      if (res.statusCode != 200) {
        return {"address": "طرابلس", "locality": "طرابلس"};
      }

      final data = jsonDecode(res.body);

      // address short
      final display = (data["display_name"] ?? "").toString();
      String shortAddress = display;
      if (shortAddress.contains(',')) {
        final parts = shortAddress.split(',');
        if (parts.length >= 2) {
          shortAddress = '${parts[0].trim()}, ${parts[1].trim()}';
        }
      }

      // locality
      final addr = data["address"] ?? {};
      final locality = (addr["road"] ??
              addr["suburb"] ??
              addr["locality"] ??
              addr["city"] ??
              "طرابلس")
          .toString();

      return {"address": shortAddress, "locality": locality};
    } catch (e) {
      debugPrint("Error reverseOnce: $e");
      return {"address": "طرابلس", "locality": "طرابلس"};
    }
  }

  Future<void> updateFirstLocation(LatLng location) async {
    try {
      addressLoading(true);
      firstLocation.value = location;

      // ✅ Reverse واحد فقط
      final r = await reverseOnce(location);
      if (isClosed) return;

      firstAddress.value = r["address"] ?? "";
      firstLocality.value = r["locality"] ?? "";

      pickupLatController.text = location.latitude.toString();
      pickupLngController.text = location.longitude.toString();

      if (nameSourceController.text.trim().isEmpty) {
        nameSourceController.text = firstLocality.value;
      }

      debugPrint("✅ تم تحديث النقطة الأولى: $location");

      final stCtrl = Get.find<ShipmentTypesController>();
      final selectedType = stCtrl.shipmentTypes
          .firstWhereOrNull((t) => t.id == stCtrl.selectedShipmentTypeId.value);

      // 🚀 بدون await
      if (stCtrl.shipmentTypes.isEmpty) {
        stCtrl.getMyShipmentTypes();
      }

      if (_shouldCalculate(selectedType)) {
        calculateDeliveryInfo();
      }
    } finally {
      addressLoading(false);
    }
  }

  Future<void> updateSecondLocation(LatLng location) async {
    try {
      addressLoading(true);
      secondLocation.value = location;

      final r = await reverseOnce(location);
      if (isClosed) return;

      secondAddress.value = r["address"] ?? "";
      secondLocality.value = r["locality"] ?? "";

      dropoffLatController.text = location.latitude.toString();
      dropoffLngController.text = location.longitude.toString();

      if (nameDestinationController.text.trim().isEmpty) {
        nameDestinationController.text = secondLocality.value;
      }

      debugPrint("✅ تم تحديث النقطة الثانية: $location");

      final stCtrl = Get.find<ShipmentTypesController>();
      final selectedType = stCtrl.shipmentTypes
          .firstWhereOrNull((t) => t.id == stCtrl.selectedShipmentTypeId.value);

      if (_shouldCalculate(selectedType)) {
        calculateDeliveryInfo();
      }
    } finally {
      addressLoading(false);
    }
  }

  bool _shouldCalculate(dataShipmentTypes? type) {
    if (type == null) return false;
    return firstLocation.value != null;
  }

  Future<void> calculateDeliveryInfo() async {
    final token = GetStorage().read('token');
    final stCtrl = Get.find<ShipmentTypesController>();

    final selectedType = stCtrl.shipmentTypes
        .firstWhereOrNull((t) => t.id == stCtrl.selectedShipmentTypeId.value);

    final bool hasSecond = secondLocation.value != null;

    final int autoDispose = switch (selectedType) {
      null => 0,
      dataShipmentTypes t when t.isAutoDispose == 0 => 0,
      dataShipmentTypes t when t.isAutoDispose == 1 => hasSecond ? 0 : 1,
      _ => 0,
    };

    final payload = {
      'source_address': nameSourceController.text.trim(),
      'source_lat': pickupLatController.text.trim(),
      'source_lng': pickupLngController.text.trim(),
      'destination_address': hasSecond ? nameDestinationController.text.trim() : nameSourceController.text.trim(),
      'destination_lat': hasSecond ? dropoffLatController.text.trim() : pickupLatController.text.trim(),
      'destination_lng': hasSecond ? dropoffLngController.text.trim() : pickupLngController.text.trim(),
      'auto_dispose': autoDispose,
      'shipment_type_id': stCtrl.selectedShipmentTypeId.value,
    };

    debugPrint("🚀 Payload for estimate: $payload");

    try {
      priceLoading(true);
      estimateError.value = ""; // تصفير الخطأ عند كل طلب جديد
      vehiclePrices.clear(); // مسح الأسعار القديمة فوراً → جميع الفئات تصبح رمادية أثناء التحميل

      final res = await http
          .post(
            Uri.parse('$apiUrl/orders/estimate'),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
              "Accept": "application/json",
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 25)); // زيادة المهلة لأن الحساب قد يستغرق وقتاً أطول

      if (isClosed) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)["data"];
        vehiclePrices.assignAll(data["vehicle_prices"] ?? []);
        debugPrint("✅ Delivery info: ${data["delivery_info"]}");
        
        // إذا كان النظام هو تخلص تلقائي (رمي مخلفات) ورجع المكب في الـ delivery_info
        if (autoDispose == 1 && data["delivery_info"] != null) {
          final deliveryInfo = data["delivery_info"];
          if (deliveryInfo["dump_lat"] != null && deliveryInfo["dump_lng"] != null) {
            // تحديث النقطة الثانية بناءً على موقع المكب المحسوب
            final dumpLat = double.tryParse(deliveryInfo["dump_lat"].toString());
            final dumpLng = double.tryParse(deliveryInfo["dump_lng"].toString());
            if (dumpLat != null && dumpLng != null) {
              secondLocation.value = LatLng(dumpLat, dumpLng);
              nameDestinationController.text = deliveryInfo["dump_name"] ?? "أقرب مكب متوفر";
            }
          }
        }
      } else {
        try {
          final errorData = jsonDecode(res.body);
          if (hasSecond || autoDispose == 1) {
            estimateError.value = errorData["message"] ?? "حدث خطأ أثناء حساب التسعيرة";
          }
        } catch (e) {
          if (hasSecond || autoDispose == 1) {
            estimateError.value = "عذراً، حدث خطأ في الخادم (Error ${res.statusCode})";
          }
        }
        debugPrint("❌ Failed to estimate: ${res.body}");
      }
    } catch (e) {
      estimateError.value = "تأكد من الاتصال بالإنترنت وحاول مجدداً";
      debugPrint("❌ Error estimating: $e");
    } finally {
      priceLoading(false);
    }
  }

  void clearFirstLocation() {
    firstLocation.value = null;
    firstAddress.value = "";
    firstLocality.value = "";
    nameSourceController.clear();
    pickupLatController.clear();
    pickupLngController.clear();
    vehiclePrices.clear();
    estimateError.value = "";
  }

  void clearSecondLocation() {
    secondLocation.value = null;
    secondAddress.value = "";
    secondLocality.value = "";
    nameDestinationController.clear();
    dropoffLatController.clear();
    dropoffLngController.clear();
    vehiclePrices.clear();
    estimateError.value = "";
  }

  void clearAllFields() {
    firstLocation.value = null;
    secondLocation.value = null;

    firstAddress.value = "";
    secondAddress.value = "";
    firstLocality.value = "";
    secondLocality.value = "";

    nameSourceController.clear();
    nameDestinationController.clear();

    pickupLatController.clear();
    pickupLngController.clear();
    dropoffLatController.clear();
    dropoffLngController.clear();

    vehiclePrices.clear();
  }

  @override
  void onClose() {
    nameSourceController.dispose();
    nameDestinationController.dispose();
    pickupLatController.dispose();
    pickupLngController.dispose();
    dropoffLatController.dispose();
    dropoffLngController.dispose();
    super.onClose();
  }
}
