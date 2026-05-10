import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:piaggio_driver/services/local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Local Notifications for the background isolate
  await LocalNotifications.init();

  final title = message.notification?.title ?? message.data['title'] ?? 'محطة للسائقين';
  final body = message.notification?.body ?? message.data['body'] ?? 'لديك إشعار جديد';

  await LocalNotifications.show(title: title, body: body);

  debugPrint('📩 BG message: ${message.data}');
}
