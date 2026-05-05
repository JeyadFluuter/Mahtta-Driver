import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:biadgo/constants/apiUrl.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class RefreshTokenController extends GetxController {
  final GetStorage getStorage = GetStorage();
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _scheduleNextRefresh();
  }

  void reschedule() {
    _scheduleNextRefresh();
  }

  void _scheduleNextRefresh() async {
    _timer?.cancel();

    final String? expStr = GetStorage().read('accessExpires') as String?;
    if (expStr == null) return;

    final expiryUtc = DateTime.parse(expStr);
    final refreshAt = expiryUtc.subtract(const Duration(seconds: 10));
    final nowUtc = DateTime.now().toUtc();

    final delay = refreshAt.isAfter(nowUtc)
        ? refreshAt.difference(nowUtc)
        : Duration.zero;

    if (delay <= const Duration(seconds: 5)) {
      _refreshToken();
    } else {
      _timer = Timer(delay, () async {
        log('🔄 Refresh access-token …');
        final ok = await _refreshToken();
        if (ok) _scheduleNextRefresh();
      });
    }
  }

  Future<bool> _refreshToken() async {
    final String? refresh = getStorage.read('refreshToken') as String?;
    if (refresh == null) return false;

    try {
      final res = await http.post(
        Uri.parse('$apiUrl/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refresh_token': refresh}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'];
        getStorage.write('token', data['token']);
        GetStorage().write('accessExpires', data['access_expires'] as String);
        getStorage.write('refreshToken', data['refresh_token']);

        log('✅ تم تحديث التوكن بنجاح');
        return true;
      }
      log('❌ فشل تحديث التوكن: ${res.body}');
    } catch (e) {
      log('❌ خطأ في الاتصال: $e');
    }
    return false;
  }

  Future<String?> refreshNow() async {
    final ok = await _refreshToken();
    if (ok) return getStorage.read('token') as String?;
    return null;
  }
}
