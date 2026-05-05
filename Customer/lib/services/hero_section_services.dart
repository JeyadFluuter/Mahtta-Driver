import 'package:biadgo/constants/apiUrl.dart';
import 'package:biadgo/models/hero_section_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HeroSectionServices {
  Future<List<HeroSectionModel>> heroSection() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/hero'),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        if (responseBody.containsKey("data") && responseBody["data"] is List) {
          return (responseBody["data"] as List)
              .map((json) => HeroSectionModel.fromJson(json))
              .toList();
        } else {
          throw Exception("الـ API لا ترجع بيانات صحيحة");
        }
      } else {
        throw Exception("فشل في تحميل الصور: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("حدث خطأ أثناء جلب البيانات: $e");
    }
  }
}
