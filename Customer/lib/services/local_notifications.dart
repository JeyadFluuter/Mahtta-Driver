import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class LocalNotifications {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for important notifications.',
      importance: Importance.max,
      playSound: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> show({
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  static Future<void> showWithImage({
    required String title,
    required String body,
    required String imageUrl,
  }) async {
    try {
      final bigPicturePath = await _downloadToFile(imageUrl, 'big_picture.jpg');
      if (bigPicturePath == null) {
        await show(title: title, body: body);
        return;
      }

      final style = BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicturePath),
        contentTitle: title,
        summaryText: body,
        hideExpandedLargeIcon: true,
      );

      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          styleInformation: style,
        ),
      );

      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
      );
    } catch (_) {
      await show(title: title, body: body);
    }
  }

  static Future<String?> _downloadToFile(String url, String fileName) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final res = await http.get(uri);
    if (res.statusCode != 200) return null;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(res.bodyBytes);
    return file.path;
  }
}
