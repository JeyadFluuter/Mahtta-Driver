import 'dart:io';
import 'package:biadgo/constants/app_theme.dart';
import 'package:biadgo/logic/controller/confirm_order_controller.dart';
import 'package:biadgo/logic/controller/my_order_controller.dart';
import 'package:biadgo/logic/controller/refresh_token_controller.dart';
import 'package:biadgo/services/local_notifications.dart';
import 'package:biadgo/services/notification.dart';
import 'package:biadgo/services/notification_delete.dart';
import 'package:biadgo/views/traceking_order_screen.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AppInitializer {
  static Future<void> initialize() async {
    await GetStorage.init();

    final MyOrderController myOrderController =
        Get.put(MyOrderController(), permanent: true);
    myOrderController.refreshData();

    Get.put(RefreshTokenController(), permanent: true);
    Get.put(ConfirmOrderController(), permanent: true);

    // نقم بجلب التوكن أولاً ثم الحذف والتسجيل بالداخل لضمان الترتيب الصحيح
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

    // ✅ تسجيل الـ listeners أولاً قبل أي return مبكر
    // هذا يضمن استقبال الإشعارات حتى لو تأخر التوكن
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint('🔁 FCM token refreshed: $newToken');
      try {
        await NotificationDelete.notificationDelete(fcmToken: newToken);
        await Notificationn.notification(
          fcmToken: newToken,
          platform: platform,
          deviceId: deviceId,
        );
      } catch (e) {
        debugPrint('⚠️ Error re-registering on token refresh: $e');
      }
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

        try {
          if (Get.isRegistered<MyOrderController>()) {
            final myOrderController = Get.find<MyOrderController>();
            await myOrderController.refreshData();

            if (myOrderController.latestActiveOrder.value != null) {
              debugPrint('🔔 Order status updated in background: ${myOrderController.latestActiveOrder.value?.status?.name}');
            }
          }
        } catch (e) {
          debugPrint('⚠️ Error updating order status: $e');
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      debugPrint('🖱️ onMessageOpenedApp data=${msg.data}');
      final orderIdStr = msg.data['order_id']?.toString() ?? msg.data['id']?.toString();
      if (orderIdStr != null) {
        final orderId = int.tryParse(orderIdStr);
        if (orderId != null) {
          Get.to(() => TracekingOrderScreen(orderId: orderId));
        }
      }
    });

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      debugPrint('🚀 getInitialMessage data=${initial.data}');
      final orderIdStr = initial.data['order_id']?.toString() ?? initial.data['id']?.toString();
      if (orderIdStr != null) {
        final orderId = int.tryParse(orderIdStr);
        if (orderId != null) {
          Get.to(() => TracekingOrderScreen(orderId: orderId));
        }
      }
    }

    // ✅ الآن نجلب التوكن ونسجله
    String? token;
    if (!kIsWeb && Platform.isIOS) {
      // على iOS، قد يتأخر APNS Token في الظهور عند أول تشغيل.
      // نحاول 10 مرات بفاصل ثانية واحدة قبل الاستسلام.
      String? apnsToken;
      for (int i = 0; i < 10; i++) {
        apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) break;
        debugPrint('⏳ APNS Token not ready yet, retry ${i + 1}/10...');
        await Future.delayed(const Duration(seconds: 1));
      }

      if (apnsToken != null) {
        token = await messaging.getToken();
        debugPrint('✅ APNS Token ready, FCM token: $token');
      } else {
        debugPrint('⛔ APNS Token still null after retries. Will rely on onTokenRefresh.');
        return; // onTokenRefresh سيتولى التسجيل لاحقاً
      }
    } else {
      token = await messaging.getToken();
    }

    debugPrint('✅ FCM token: $token');

    if (token == null || token.isEmpty) return;

    // تسجيل التوكن في السيرفر
    try {
      await NotificationDelete.notificationDelete(fcmToken: token);
      await Notificationn.notification(
        fcmToken: token,
        platform: platform,
        deviceId: deviceId,
      );
    } catch (e) {
      debugPrint('⚠️ Error registering notification: $e');
    }
  }
}
