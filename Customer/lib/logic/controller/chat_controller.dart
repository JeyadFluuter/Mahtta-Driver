import 'dart:convert';
import 'package:biadgo/constants/apiUrl.dart';
import 'package:biadgo/logic/controller/me_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ChatController extends GetxController {
  final MeController meController = Get.put(MeController());

  var conversationId = RxnInt();
  var conversationType = RxnString();

  final participants = [
    {"id": 1, "type": "CUSTOMER"},
    {"id": 1, "type": "DRIVER"},
  ];

  Future<void> createConversation() async {
    final token = GetStorage().read<String>('token');
    final body = {
      'participants': participants,
      'conversation_type': 'PRIVATE',
      'subject': 'Order Discussion',
    };

    try {
      final response = await http.post(
        Uri.parse(chat),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('⏪ RAW RESPONSE: ${response.body}');

        // استخرج الـ id من داخل data وخزّنه في الـ RxnInt
        final id = decoded['data']?['id'] as int?;
        conversationId.value = id;
        debugPrint('✔️ conversationId: $id');

        final type = decoded['data']?['sender_type'] as String?;
        conversationType.value = type!;
        debugPrint('✔️ conversationType: $type');

        Get.snackbar(
          'نجاح',
          'تم إنشاء المحادثة بنجاح (ID: $id)',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'فشل',
          'حدث خطأ (${response.statusCode})',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'لا يمكن الاتصال بالخادم',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('خطأ أثناء إنشاء المحادثة: $e');
    }
  }
}
