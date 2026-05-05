import 'dart:convert';
import 'package:biadgo/constants/apiUrl.dart';
import 'package:biadgo/models/new_location_model.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class LocationsServices {
  Future<(List<DataLocation>, int)> fetchPage({
    required int page,
    int perPage = 15,
  }) async {
    final GetStorage getStorage = GetStorage();
    final token = getStorage.read('token') as String?;
    if (token == null) throw Exception('Token not found');

    final res = await http.get(
      Uri.parse('$apiUrl/addresses?page=$page&per_page=$perPage'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final Map<String, dynamic> j = jsonDecode(res.body);
    final raw = j['data']?['pagination']?['total_pages'];
    final totalPages =
        raw is int ? raw : int.tryParse(raw?.toString() ?? '') ?? 1;
    final items = locationFromJson(res.body);
    return (items, totalPages);
  }
}
