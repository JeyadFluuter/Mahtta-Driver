import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/appInitializer.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/firebase_messaging_handler.dart';
import 'package:piaggio_driver/firebase_options.dart';
import 'package:piaggio_driver/routes/routes.dart';
import 'package:piaggio_driver/logic/controller/me_controller.dart';
import 'package:piaggio_driver/logic/controller/my_orders_controller.dart';
import 'package:piaggio_driver/logic/controller/order_accepted_controller.dart';
import 'package:piaggio_driver/logic/controller/order_tracking_controller.dart';
import 'package:piaggio_driver/logic/controller/rejection_order_controller.dart';
import 'package:piaggio_driver/services/appServices.dart';
import 'package:piaggio_driver/services/local_notifications.dart';
import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:piaggio_driver/logic/controller/order_request_controller.dart';
import 'package:piaggio_driver/model/order_request_model.dart';
import 'package:piaggio_driver/services/order_request_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocalNotifications.init();
  
  // Initialize Controllers early for FCM handlers
  Get.put(OrderController(), permanent: true);
  Get.put(OrderAcceptedController(), permanent: true);
  
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // Foreground message handler
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('📩 FG message: ${message.data}');
    _handleNotificationData(message.data);
    final title = message.notification?.title ?? message.data['title'] ?? 'محطة للسائقين';
    final body = message.notification?.body ?? message.data['body'] ?? 'لديك إشعار جديد';
    LocalNotifications.show(title: title, body: body);
  });

  // Handle notification click when app is in background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('📩 Notification Clicked (Background): ${message.data}');
    _handleNotificationData(message.data);
  });

  // Handle notification click when app is terminated
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      debugPrint('📩 Notification Clicked (Terminated): ${message.data}');
      _handleNotificationData(message.data);
    }
  });

  await Get.putAsync<AppServices>(() async => AppServices().init(),
      permanent: true);
  await AppInitializer.initialize();

  runApp(const MyApp());
}

void _handleNotificationData(Map<String, dynamic> data) {
  debugPrint('📥 Full Notification Payload: $data');
  try {
    // 1. Check for full order data first
    final dynamic orderDataRaw = data['order_data'] ?? data['order'];
    if (orderDataRaw != null) {
      Map<String, dynamic> orderJson;
      if (orderDataRaw is String) {
        orderJson = jsonDecode(orderDataRaw);
      } else if (orderDataRaw is Map) {
        orderJson = Map<String, dynamic>.from(orderDataRaw);
      } else {
        return;
      }
      
      debugPrint('🔍 Decoded Order JSON: $orderJson');
      final order = OrderData.fromJson(orderJson);
      final orderCtrl = Get.find<OrderController>();
      orderCtrl.setCurrentOrder(order);
      
      if (Get.isRegistered<OrderAcceptedController>()) {
        Get.find<OrderAcceptedController>().setOrderId(order.id);
      }
      debugPrint('📦 Order set from notification data: ${order.id}');
      return;
    }

    // 2. If no full data, check for order_id to fetch it from API
    final dynamic orderIdRaw = data['order_id'] ?? data['id'];
    if (orderIdRaw != null) {
      final int? orderId = int.tryParse(orderIdRaw.toString());
      if (orderId != null) {
        debugPrint('📡 Notification only had ID ($orderId), fetching details...');
        // We need PusherService to be initialized
        if (Get.isRegistered<PusherService>()) {
          Get.find<PusherService>().fetchOrderById(orderId);
        } else {
          // If not registered yet (app just started), put it or wait
          Get.put(PusherService()).fetchOrderById(orderId);
        }
      }
    }
  } catch (e) {
    debugPrint('❌ Error handling notification data: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    AppDimensions.initialize(context);

    return GetMaterialApp(
      title: 'Mahtta Driver',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.light,
      locale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      initialRoute: AppRoutes.splashScreen,
      getPages: AppRoutes.routes,
      initialBinding: BindingsBuilder(() {
        Get.put(MeController(), permanent: true);
        Get.put(OrderTrackingController(), permanent: true);
        Get.put(RejectionOrderController(), permanent: true);
        Get.lazyPut<MyOrderController>(() => MyOrderController(), fenix: true);
      }),
    );
  }
}
