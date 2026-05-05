/* lib/logic/controller/image_slider_controller.dart */
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'hero_section_controller.dart';

class ImageSliderController extends GetxController {
  final HeroSectionController heroSection = Get.find();

  final RxInt currentIndex = 0.obs;
  late final PageController pageController;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  @override
  void onReady() {
    super.onReady();
    _startAutoSlide();
  }

  @override
  void onClose() {
    _timer?.cancel();
    pageController.dispose();
    super.onClose();
  }

  void _startAutoSlide() {
    if (heroSection.heroImages.isEmpty) return;

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!pageController.hasClients) return;

      final next = (currentIndex.value + 1) % heroSection.heroImages.length;
      currentIndex.value = next;
      pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }
}
