import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NotificationIcon extends StatefulWidget {
  const NotificationIcon({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotificationIconState createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  final int _notificationCount = 4;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Get.theme.primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),
        if (_notificationCount > 0)
          Positioned(
            right: 3,
            top: 3,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Get.theme.primaryColor,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                '$_notificationCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
