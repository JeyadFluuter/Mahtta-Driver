import 'dart:convert';

class NotificationModel {
  final String fcmToken;
  final String platform;
  final int deviceId;

  NotificationModel({
    required this.fcmToken,
    required this.platform,
    required this.deviceId,
  });

  factory NotificationModel.fromJson(String str) =>
      NotificationModel.fromMap(json.decode(str));

  factory NotificationModel.fromMap(Map<String, dynamic> json) =>
      NotificationModel(
        fcmToken: json["fcm_token"] ?? '',
        platform: json["platform"] ?? '',
        deviceId: json["device_id"] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        "fcm_token": fcmToken,
        "platform": platform,
        "device_id": deviceId,
      };
}
