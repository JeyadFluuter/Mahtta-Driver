import 'dart:async';
import 'package:biadgo/constants/appInitializer.dart';
import 'package:biadgo/firebase_messaging_handler.dart';
import 'package:biadgo/firebase_options.dart';
import 'package:biadgo/logic/controller/my_order_controller.dart';
import 'package:biadgo/services/local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'constants/app_dimensions.dart';
import 'logic/controller/me_controller.dart';
import 'logic/controller/hero_section_controller.dart';
import 'logic/controller/image_slider_controller.dart';
import 'logic/controller/my_locations_controller.dart';
import 'routes/routes.dart';
import 'constants/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // توحيد التصميم وجعل الشريط العلوي شفافاً في جميع الإصدارات
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  await Future.wait([
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ),
    LocalNotifications.init(),
  ]);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  AppInitializer.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppDimensions.initialize(context);
    return GetMaterialApp(
      title: 'Mahtta',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.light,
      locale: const Locale("ar"),
      supportedLocales: const [Locale("ar")],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutes.splashScreen,
      getPages: AppRoutes.routes,
      initialBinding: BindingsBuilder(() {
        Get.put<MeController>(MeController(), permanent: true);
        Get.lazyPut<HeroSectionController>(() => HeroSectionController(),
            fenix: true);
        Get.lazyPut<ImageSliderController>(() => ImageSliderController(),
            fenix: true);
        Get.lazyPut<MyLocationsController>(() => MyLocationsController(),
            fenix: true);
        Get.put(MyOrderController(), permanent: true);
      }),
    );
  }
}
