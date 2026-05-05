// import 'dart:convert';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:biadgo/constants/apiUrl.dart';
// import 'package:flutter/material.dart';

// class MapController extends GetxController {
//   List<LatLng> savedFirstLocations = [
//     const LatLng(32.8841, 13.1852),
//     const LatLng(32.8950, 13.1800),
//   ];

//   List<LatLng> savedSecondLocations = [
//     const LatLng(32.8900, 13.1900),
//     const LatLng(32.9000, 13.2000),
//   ];
//   Rx<LatLng?> firstLocation = Rx<LatLng?>(null);
//   Rx<LatLng?> secondLocation = Rx<LatLng?>(null);
//   RxString firstAddress = "".obs;
//   RxString secondAddress = "".obs;
//   RxString firstLocality = "".obs;
//   RxString secondLocality = "".obs;
//   RxList<dynamic> vehiclePrices = <dynamic>[].obs;

//   final TextEditingController nameSourceController = TextEditingController();
//   final TextEditingController nameDestinationController =
//       TextEditingController();
//   final TextEditingController pickupLatController = TextEditingController();
//   final TextEditingController pickupLngController = TextEditingController();
//   final TextEditingController dropoffLatController = TextEditingController();
//   final TextEditingController dropoffLngController = TextEditingController();

//   Future<void> updateFirstLocation(LatLng location) async {
//     firstLocation.value = location;
//     String address = await getAddressFromLatLng(location) ?? "";
//     String locality = await getLocalityFromLatLng(location) ?? "";
//     firstAddress.value = address;
//     firstLocality.value = locality;
//     pickupLatController.text = location.latitude.toString();
//     pickupLngController.text = location.longitude.toString();

//     if (nameSourceController.text.trim().isEmpty) {
//       nameSourceController.text = locality;
//     }

//     debugPrint("تم تحديث النقطة الأولى:");
//     debugPrint("الإحداثيات: ${location.latitude}, ${location.longitude}");
//     debugPrint("العنوان: $address");
//     debugPrint("اسم المنطقة: $locality");
//   }

//   Future<void> updateSecondLocation(LatLng location) async {
//     secondLocation.value = location;
//     String address = await getAddressFromLatLng(location) ?? "";
//     String locality = await getLocalityFromLatLng(location) ?? "";
//     secondAddress.value = address;
//     secondLocality.value = locality;
//     dropoffLatController.text = location.latitude.toString();
//     dropoffLngController.text = location.longitude.toString();

//     if (nameDestinationController.text.trim().isEmpty) {
//       nameDestinationController.text = locality;
//     }

//     debugPrint("تم تحديث النقطة الثانية:");
//     debugPrint("الإحداثيات: ${location.latitude}, ${location.longitude}");
//     debugPrint("العنوان: $address");
//     debugPrint("اسم المنطقة: $locality");

//     await calculateDeliveryInfo();
//   }

//   Future<String?> getAddressFromLatLng(LatLng position) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );
//       if (placemarks.isNotEmpty) {
//         final Placemark place = placemarks.first;
//         return "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}, ${place.street}";
//       }
//     } catch (e) {
//       debugPrint("Error in reverse geocoding: $e");
//     }
//     return null;
//   }

//   Future<String?> getLocalityFromLatLng(LatLng position) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );
//       if (placemarks.isNotEmpty) {
//         final Placemark place = placemarks.first;
//         if (place.street != null && place.street!.isNotEmpty) {
//           return place.street;
//         } else {
//           return place.locality;
//         }
//       }
//     } catch (e) {
//       debugPrint("Error in reverse geocoding: $e");
//     }
//     return null;
//   }

//   Future<void> calculateDeliveryInfo() async {
//     final token = GetStorage().read('token');
//     try {
//       final data = {
//         'source_address': nameSourceController.text.trim(),
//         'source_lat': pickupLatController.text.trim(),
//         'source_lng': pickupLngController.text.trim(),
//         'destination_address': nameDestinationController.text.trim(),
//         'destination_lat': dropoffLatController.text.trim(),
//         'destination_lng': dropoffLngController.text.trim(),
//       };

//       final response = await http.post(
//         Uri.parse('$apiUrl/orders/estimate'),
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//         body: json.encode(data),
//       );

//       if (response.statusCode == 200) {
//         final decoded = json.decode(response.body);
//         final data = decoded["data"];

//         final List<dynamic> vehiclePricesList = data["vehicle_prices"];
//         final deliveryInfo = data["delivery_info"];

//         if (vehiclePricesList.isNotEmpty) {
//           vehiclePrices.assignAll(vehiclePricesList);
//           debugPrint("Vehicle prices: $vehiclePrices");
//         }
//         debugPrint("Delivery info: $deliveryInfo");
//       } else {
//         debugPrint("Failed to calculate delivery info: ${response.body}");
//       }
//     } catch (e) {
//       debugPrint("Error in calculating delivery info: $e");
//     }
//   }

//   void clearAllFields() {
//     firstLocation.value = null;
//     secondLocation.value = null;
//     firstAddress.value = "";
//     secondAddress.value = "";
//     firstLocality.value = "";
//     secondLocality.value = "";
//     nameSourceController.clear();
//     nameDestinationController.clear();
//     pickupLatController.clear();
//     pickupLngController.clear();
//     dropoffLatController.clear();
//     dropoffLngController.clear();
//     vehiclePrices.clear();
//   }
// }
