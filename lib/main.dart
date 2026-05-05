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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocalNotifications.init();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await Get.putAsync<AppServices>(() async => AppServices().init(),
      permanent: true);
  await AppInitializer.initialize();

  runApp(const MyApp());
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
        Get.put(OrderAcceptedController(), permanent: true);
        Get.put(RejectionOrderController(), permanent: true);
        Get.lazyPut<MyOrderController>(() => MyOrderController(), fenix: true);
      }),
    );
  }
}
