import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../constants/apiUrl.dart';
import '../models/rating_driver_model.dart';

class RatingService {
  Future<RatingResponse?> ratingDriver({
    required int orderId,
    required String rating,
    required String comment,
  }) async {
    final url = Uri.parse('$apiUrl/orders/rate-driver');
    final GetStorage getStorage = GetStorage();
    final token = getStorage.read('token') as String?;

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: {
        'order_id': orderId.toString(),
        'rating': rating,
        'comment': comment,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap =
          json.decode(response.body) as Map<String, dynamic>;

      return RatingResponse.fromJson(jsonMap);
    } else {
      debugPrint('خطاء في الاستجابة: ${response.statusCode}');
      debugPrint('نص الاستجابة: ${response.body}');
      return null;
    }
  }
}
