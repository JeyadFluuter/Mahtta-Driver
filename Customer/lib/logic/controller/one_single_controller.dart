// import 'dart:convert';
// import 'package:biadgo/constants/apiUrl.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:http/http.dart' as http;

// class OneSingleController extends GetxController {
//   Future<void> oneSingle() async {
//     try {
//       var data = {
//         'platform': "android",
//         'one_signal_id': "",
//       };

//       final token = GetStorage().read('token');
//       var response = await http.post(
//         Uri.parse('$apiUrl/verify_code'),
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//         body: json.encode(data),
//       );

//       if (response.statusCode == 200) {
//         print(response.body);
//       } else {
//         Get.snackbar("عملية التحقق", "عملية التحقق غير صحيحة",
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 4),
//             icon: const Icon(Icons.error));
//       }
//     } catch (e) {
//       print(e);
//       Get.snackbar("خطأ", "حدث خطأ أثناء التحقق");
//     }
//   }
// }
