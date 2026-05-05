import 'package:get/get.dart';
import 'package:piaggio_driver/views/Auth/User_SignUp/otp_SignUp_screen.dart';
import 'package:piaggio_driver/views/Auth/welcome_screen.dart';
import 'package:piaggio_driver/views/splash_screen.dart';
import 'package:piaggio_driver/views/choose_zoon_maps_screen.dart';
import '../views/home_screen.dart';

class AppRoutes {
  static const splashScreen = AppRoute.splashScreen;
  static const welcomeScreen = AppRoute.welcomeScreen;
  static const homescreen = AppRoute.homescreen;
  static const loginscreen = AppRoute.loginscreen;
  static const navbar = AppRoute.navbar;
  static const orderscreen = AppRoute.orderscreen;
  static const otpSignup = AppRoute.otpSignup;
  static const selectZone = AppRoute.selectZone;

  static final routes = [
    GetPage(
      name: AppRoute.splashScreen,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoute.welcomeScreen,
      page: () => const WelcomeScreen(),
    ),
    GetPage(
      name: AppRoute.homescreen,
      page: () => HomeScreen(),
    ),
    GetPage(
      name: AppRoute.otpSignup,
      page: () => OtpScreenSignup(),
    ),
    GetPage(
      name: AppRoute.selectZone,
      page: () => const SelectZoneMap(),
    ),
  ];
}

class AppRoute {
  static const selectZone = '/select_zone';
  static const splashScreen = '/splashScreen';
  static const welcomeScreen = '/welcomeScreen';
  static const homescreen = '/homescreen';
  static const loginscreen = '/loginscreen';
  static const navbar = '/navbar';
  static const orderscreen = '/orderscreen';
  static const otpSignup = '/otpSignup';
}
