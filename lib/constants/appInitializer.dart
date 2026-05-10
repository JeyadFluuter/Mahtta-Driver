// ignore: file_names
import 'dart:io';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:piaggio_driver/services/local_notifications.dart';
import 'package:piaggio_driver/services/notification.dart';
import 'package:piaggio_driver/services/notification_delete.dart';

class AppInitializer {
  static Future<void> initialize() async {
    await GetStorage.init();

    await NotificationDelete.notificationDelete();

    initFCMAndRegisterToken();
  }

  static Future<void> initFCMAndRegisterToken() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('🔔 FCM permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('⛔ Notifications permission denied');
      return;
    }

    String? token;
    try {
      if (!kIsWeb && Platform.isIOS) {
        // iOS requires APNS token before getting FCM token
        String? apnsToken = await messaging.getAPNSToken();
        if (apnsToken == null) {
          await Future.delayed(const Duration(seconds: 2));
          apnsToken = await messaging.getAPNSToken();
        }
        if (apnsToken != null) {
          token = await messaging.getToken();
        } else {
          debugPrint('⚠️ APNS token not available. Push notifications might not work.');
        }
      } else {
        token = await messaging.getToken();
      }
      debugPrint('✅ FCM token: $token');
    } catch (e) {
      debugPrint('⚠️ Error getting FCM token: $e');
    }

    if (token == null || token.isEmpty) return;

    final platform = kIsWeb
        ? 'web'
        : (Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'other'));

    String? deviceId;
    try {
      deviceId = await FirebaseInstallations.instance.getId();
      debugPrint('📌 FID (device_id): $deviceId');
    } catch (e) {
      debugPrint('⚠️ Could not get Installation ID: $e');
    }

    await Notificationn.notification(
      fcmToken: token,
      platform: platform,
      deviceId: deviceId,
    );

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint('🔁 FCM token refreshed: $newToken');
      await Notificationn.notification(
        fcmToken: newToken,
        platform: platform,
        deviceId: deviceId,
      );
    });
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      debugPrint('🚀 getInitialMessage data=${initial.data}');
    }
  }
}
