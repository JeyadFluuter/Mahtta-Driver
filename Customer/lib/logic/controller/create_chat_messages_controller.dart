import 'dart:convert';
import 'package:biadgo/constants/apiUrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'chat_controller.dart';

class CreateChatMessagesController extends GetxController {
  final TextEditingController messageController = TextEditingController();
  final ChatController chatCtrl = Get.find<ChatController>();
  final GetStorage getStorage = GetStorage();
  Future<void> createChatMessage() async {
    final String? token = getStorage.read('token') as String?;
    final convId = chatCtrl.conversationId.value;
    final messageText = messageController.text.trim();

    if (messageText.isEmpty) {
      Get.snackbar('تنبيه', 'رجاءً ادخل نص الرسالة',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final body = {
      'conversation_id': convId,
      'message': messageText,
    };

    try {
      final response = await http.post(
        Uri.parse(chatMessage),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        debugPrint('⏪ RAW RESPONSE MESSAGE: $decoded');

        Get.snackbar('نجاح', 'تم إرسال الرسالة بنجاح',
            backgroundColor: Colors.green, colorText: Colors.white);

        messageController.clear();
      } else {
        Get.snackbar('فشل', 'حدث خطأ (${response.statusCode})',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('خطأ', 'لا يمكن الاتصال بالخادم',
          backgroundColor: Colors.red, colorText: Colors.white);
      debugPrint('خطأ أثناء إرسال الرسالة: $e');
    }
  }
}
