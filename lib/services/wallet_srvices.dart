import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/model/wallet_model.dart';

class WalletServices {
  final _box = GetStorage();

  Future<WalletResponse?> fetchWallet() async {
    final token = _box.read('token');
    try {
      final res = await http.get(
        Uri.parse('$apiUrl/wallet'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        return WalletResponse.fromJson(res.body);
      } else {
        debugPrint('⛔️ Wallet API error ${res.statusCode}: ${res.body}');
        return null;
      }
    } catch (e) {
      debugPrint('⛔️ Wallet API exception: $e');
      return null;
    }
  }
}
