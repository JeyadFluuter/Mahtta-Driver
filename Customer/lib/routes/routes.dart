import 'package:biadgo/logic/binding/home_screen_binding.dart';
import 'package:biadgo/logic/binding/image_slider_binding.dart';
import 'package:biadgo/logic/binding/my_order_binding.dart';
import 'package:biadgo/logic/binding/profile_binding.dart';
import 'package:biadgo/logic/binding/splash_binding.dart';
import 'package:biadgo/views/Auth/welcome_screen.dart';
import 'package:biadgo/views/my_order_screen1.dart';
import 'package:biadgo/views/profile_screen.dart';
import 'package:biadgo/views/splash_screen.dart';
import 'package:biadgo/widgets/HomeScreen/image_slider.dart';
import 'package:biadgo/widgets/Orders/make_order.dart';
import 'package:biadgo/widgets/nav_bar.dart';
import 'package:get/get.dart';
import '../views/Auth/login_screen.dart';
import '../views/Auth/User_SignUp/otp_screen_signUp.dart';
import '../views/home_screen.dart';

class AppRoutes {
  static const splashScreen = Route.splashScreen;
  static const welcomeScreen = Route.welcomeScreen;
  static const homescreen = Route.homescreen;
  static const loginscreen = Route.loginscreen;
  static const otpSignup = Route.otpSignup;
  static const navbar = Route.navbar;
  static const order = Route.order;
  static const myOrder = Route.myOrder;
  static const profile = Route.profile;
  static const openStreetMap = Route.openStreetMap;
  static const imageSlider = Route.imageSlider;
  static const tracekingOrderScreen = Route.tracekingOrderScreen;
  static final routes = [
    GetPage(
      name: Route.splashScreen,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Route.welcomeScreen,
      page: () => const WelcomeScreen(),
    ),
    GetPage(
      name: Route.homescreen,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Route.loginscreen,
      page: () => LoginScreen(),
    ),
    GetPage(
      name: Route.navbar,
      page: () => NavBar(),
    ),
    // GetPage(
    //   name: Route.order,
    //   page: () => OrderScreen(),
    //   binding: OrderBinding(),
    // ),
    GetPage(
      name: Route.myOrder,
      page: () => MyOrderScreen1(),
      binding: MyOrderBinding(),
    ),
    GetPage(
      name: Route.profile,
      page: () => ProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Route.openStreetMap,
      page: () => const MakeOrder(),
      binding: MyOrderBinding(),
    ),
    GetPage(
      name: Route.imageSlider,
      page: () => const ImageSliderScreen(),
      binding: ImageSliderBinding(),
    ),
    // GetPage(
    //   name: Route.tracekingOrderScreen,
    //   page: () => const TracekingOrderScreen(),
    // ),
    GetPage(
      name: Route.otpSignup,
      page: () => OtpScreenSignup(),
    ),
  ];
}

class Route {
  static const splashScreen = '/splashScreen';
  static const welcomeScreen = '/welcomeScreen';
  static const homescreen = '/homescreen';
  static const loginscreen = '/loginscreen';
  static const navbar = '/navbar';
  static const order = '/order';
  static const myOrder = '/myOrder';
  static const profile = '/profile';
  static const openStreetMap = '/openStreetMap';
  static const imageSlider = '/imageSlider';
  static const tracekingOrderScreen = '/tracekingOrderScreen';
  static const otpSignup = '/otpSignup';
}
