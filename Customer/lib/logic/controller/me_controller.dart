import 'dart:async';
import 'dart:convert';
import 'package:biadgo/constants/apiUrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class MeController extends GetxController {
  final GetStorage getStorage = GetStorage();
  final firstname = ''.obs;
  final lastname = ''.obs;
  final email = ''.obs;
  final isActive = ''.obs;
  final isVerified = ''.obs;
  final phone = ''.obs;
  final image = ''.obs;
  final city = ''.obs;
  final id = ''.obs;
  final isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    meUser(); // ما فيها await هنا
  }

  Future<void> meUser() async {
    try {
      isLoading.value = true;
      final token = getStorage.read('token') as String?;
      if (token != null && token.isNotEmpty) {
        await me(token);
      } else {
        debugPrint('لا يوجد توكن محفوظ.');
      }
    } catch (e, st) {
      debugPrint('خطأ أثناء قراءة التوكن من التخزين الآمن: $e\n$st');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> me(String token) async {
    try {
      final uri = Uri.parse('$apiUrl/me');
      final response = await http.get(uri, headers: {
        "Authorization": "Bearer $token"
      }).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final userData = responseBody['data'] ?? {};

        firstname.value = (userData['first_name'] ?? '').toString();
        lastname.value = (userData['last_name'] ?? '').toString();
        email.value = (userData['email'] ?? '').toString();
        phone.value = (userData['phone'] ?? '').toString();
        isActive.value = (userData['is_active'] ?? '').toString();
        isVerified.value = (userData['is_verified'] ?? '').toString();
        city.value = (userData['city'] ?? '').toString();
        id.value = (userData['id'] ?? '').toString();

        final imgPath = userData['image'];
        image.value = (imgPath == null || imgPath.toString().isEmpty)
            ? ''
            : '$ImageUrl$imgPath';

        debugPrint("responseBody = $responseBody");
        debugPrint("تم جلب وتخزين بيانات المستخدم ✅");
      } else {
        debugPrint('فشل الجلب: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException catch (e) {
      debugPrint('ClientException: $e');
    } on FormatException catch (e) {
      debugPrint('JSON FormatException: $e');
    } on TimeoutException {
      debugPrint('انتهت مهلة الطلب');
    } catch (e, st) {
      debugPrint("خطأ أثناء استرجاع البيانات: $e\n$st");
    }
  }
}
