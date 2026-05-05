import 'package:biadgo/constants/apiUrl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/login_model.dart';
import 'dart:convert';

class AuthService {
  Future<LoginResponse?> register({
    required String firstName,
    required String lastName,
    required String city,
    required String phone,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String image,
  }) async {
    try {
      final Uri url = Uri.parse('$apiUrl/register');

      final response = await http.post(
        url,
        body: {
          'first_name': firstName,
          'last_name': lastName,
          'city': city,
          'phone': phone,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'image': image,
        },
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final login = LoginResponse.fromJson(response.body);
        return login;
      } else {
        final rawBody = response.body;
        debugPrint('خطاء في التسجيل: ${response.statusCode}');
        debugPrint('نص الاستجابة: $rawBody');
        throw rawBody;
      }
    } catch (e) {
      debugPrint('خطأ أثناء الإتصال بالخادم: $e');
      rethrow;
    }
  }

  String? _extractServerError(String body) {
    try {
      final m = jsonDecode(body);
      if (m is Map) {
        if (m['errors'] is Map) {
          final errors = m['errors'] as Map;
          for (final v in errors.values) {
            if (v is List && v.isNotEmpty) return v.first.toString();
            if (v is String && v.isNotEmpty) return v;
          }
        }
        if (m['message'] is String && (m['message'] as String).isNotEmpty) {
          return m['message'] as String;
        }
      }
    } catch (_) {}
    return null;
  }

  String _statusMsg(int code) {
    switch (code) {
      case 422:
        return 'البيانات غير صالحة.';
      case 409:
        return 'الطلب متعارض.';
      case 401:
        return 'غير مصرح.';
      case 500:
        return 'خطأ في الخادم.';
      default:
        return 'حدث خطأ ($code).';
    }
  }

  String _arabic(String msg) {
    if (msg.contains('غير مسجل لدينا')) return msg;
    if (msg.contains('غير صحيحة')) return msg;
    if (msg.contains('معطل حالياً')) return msg;
    if (msg.contains('يرجى تفعيل الحساب')) return 'UNVERIFIED_ACCOUNT';

    final lower = msg.toLowerCase();
    if (lower.contains('invalid') && lower.contains('phone')) {
      return 'رقم الهاتف المدخل غير مسجل أو غير صحيح.';
    }
    if (lower.contains('invalid') && lower.contains('password')) {
      return 'كلمة المرور غير صحيحة، يرجى المحاولة مرة أخرى.';
    }
    if (lower.contains('phone') && lower.contains('taken')) {
      return 'رقم الهاتف مستخدم مسبقًا.';
    }
    if (lower.contains('email') && lower.contains('taken')) {
      return 'البريد الإلكتروني مستخدم مسبقًا.';
    }
    if (lower.contains('credentials')) {
      return 'خطأ في بيانات الدخول، تأكد من الرقم وكلمة المرور.';
    }
    if (lower.contains('validation')) {
      return 'يرجى التأكد من صحة البيانات المدخلة.';
    }
    return msg;
  }

  Future<LoginResponse?> login({
    required String phone,
    required String password,
  }) async {
    try {
      final Uri url = Uri.parse('$apiUrl/login');

      final response = await http.post(
        url,
        body: {
          'phone': phone,
          'password': password,
        },
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        final loginResponse = LoginResponse.fromJson(responseBody);
        return loginResponse;
      } else {
        debugPrint('خطاء في الاستجابة: ${response.statusCode}');
        debugPrint('نص الاستجابة: ${response.body}');

        final rawBody = response.body;
        final extracted =
            _extractServerError(rawBody) ?? _statusMsg(response.statusCode);
        final msg = _arabic(extracted);
        throw msg;
      }
    } catch (e) {
      debugPrint('خطأ أثناء الإتصال بالسيرفر: $e');
      if (e is String) rethrow;
      throw "تعذر الاتصال بالخادم. تأكد من اتصال الإنترنت.";
    }
  }

  Future<bool> deleteAccount({required String token}) async {
    try {
      final Uri url = Uri.parse('$apiUrl/delete-account');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        debugPrint('Account deleted successfully');
        return true;
      } else {
        debugPrint('Failed to delete account: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        final rawBody = response.body;
        final extracted =
            _extractServerError(rawBody) ?? _statusMsg(response.statusCode);
        throw _arabic(extracted);
      }
    } catch (e) {
      debugPrint('Error deleting account: $e');
      rethrow;
    }
  }
}
