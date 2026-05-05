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

    await initFCMAndRegisterToken();
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

    final token = await messaging.getToken();
    debugPrint('✅ FCM token: $token');

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
    FirebaseMessaging.onMessage.listen((msg) async {
      final title = msg.notification?.title ?? 'تنبيه';
      final body = msg.notification?.body ?? '';
      final imageUrl =
          msg.notification?.android?.imageUrl ?? msg.data['image']?.toString();

      if (imageUrl != null && imageUrl.isNotEmpty) {
        await LocalNotifications.showWithImage(
          title: title,
          body: body,
          imageUrl: imageUrl,
        );
      } else {
        await LocalNotifications.show(title: title, body: body);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      debugPrint('🖱️ onMessageOpenedApp data=${msg.data}');
    });

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      debugPrint('🚀 getInitialMessage data=${initial.data}');
    }
  }
}
