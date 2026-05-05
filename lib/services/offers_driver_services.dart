import 'dart:convert';
import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/model/offers_driver_model.dart';

class OffersDriverServices {
  final _box = GetStorage();

  Future<List<OffersDriverModel>> fetchOffers() async {
    final token = _box.read<String>('token') ?? '';
    final url = Uri.parse('$apiUrl/offers');

    final res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final list = decoded['data'] as List<dynamic>? ?? [];
      final offers = list.map((e) => OffersDriverModel.fromMap(e)).toList();
      return offers;
    }

    throw Exception('خطأ فى جلب العروض: ${res.statusCode}');
  }
}
