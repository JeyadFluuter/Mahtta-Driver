import 'package:biadgo/constants/apiUrl.dart';
import 'package:biadgo/models/view_messages_model.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ViewMessagesServices {
  Future<List<ViewMessagesModel>> viewMessages({
    required int conversationId,
    required int page,
  }) async {
    try {
      final GetStorage getStorage = GetStorage();
      final token = getStorage.read('token') as String?;

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$apiUrl/orders/my-orders/$conversationId/$page'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        debugPrint("API Response: $responseBody");
        return viewmessagesFromJson(responseBody);
      } else {
        throw Exception(
            'Failed to load messages. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in viewMessages: $e');
      rethrow; // أو return []; حسب متطلبات التطبيق
    }
  }
}
