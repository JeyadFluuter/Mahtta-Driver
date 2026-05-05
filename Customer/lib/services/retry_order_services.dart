import 'dart:convert';
import 'package:biadgo/constants/apiUrl.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class RetryOrderServices {
  Future<bool> retryOrder(int orderId) async {
    try {
      final token = GetStorage().read('token') as String?;
      if (token == null) return false;

      final res = await http.post(
        Uri.parse('$apiUrl/orders/order/$orderId/retry'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return body['error'] == 0 || body['status'] == 'success';
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
