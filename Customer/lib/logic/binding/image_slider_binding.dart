/* lib/bindings/initial_binding.dart */
import 'package:biadgo/logic/controller/hero_section_controller.dart';
import 'package:biadgo/logic/controller/image_slider_controller.dart';
import 'package:get/get.dart';

class ImageSliderBinding extends Bindings {
  @override
  void dependencies() {
    // permanent: true لأنّ السلايدر موجود في الرئيسيّة
    Get.put<HeroSectionController>(HeroSectionController(), permanent: true);
    Get.put<ImageSliderController>(ImageSliderController(), permanent: true);
  }
}
