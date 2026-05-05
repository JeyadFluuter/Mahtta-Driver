/* lib/widgets/home_screen/image_slider.dart */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants/app_dimensions.dart';
import '../../logic/controller/hero_section_controller.dart';
import '../../logic/controller/image_slider_controller.dart';

class ImageSliderScreen extends GetView<ImageSliderController> {
  const ImageSliderScreen({super.key});

  HeroSectionController get hero => Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (hero.isLoading.value) return _buildShimmer(context);
      if (hero.errorMessage.isNotEmpty || hero.heroImages.isEmpty) {
        return _buildFallback(context);
      }

      return Column(
        children: [
          _buildPageView(context),
          const SizedBox(height: AppDimensions.paddingSmall),
          Obx(() {
            final count = hero.heroImages.length;
            if (count == 0) return const SizedBox.shrink();
            return SmoothPageIndicator(
              controller: controller.pageController,
              count: count,
              effect: ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Get.theme.primaryColor,
                dotColor: Colors.grey,
              ),
            );
          }),
        ],
      );
    });
  }

  /*────────── Widgets مساعدة──────────*/
  Widget _buildPageView(BuildContext ctx) => Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingSmall),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: AppDimensions.screenHeight * .20,
            width: double.infinity,
            child: PageView.builder(
              controller: controller.pageController,
              itemCount: hero.heroImages.length,
              onPageChanged: (i) => controller.currentIndex.value = i,
              itemBuilder: (_, i) => _networkImage(hero.heroImages[i]),
            ),
          ),
        ),
      );

  Widget _networkImage(String url) => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          url,
          width: double.infinity,
          height: AppDimensions.screenHeight * .20,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : _buildShimmerImage(),
          errorBuilder: (_, __, ___) => _fallbackImage(),
        ),
      );

  Widget _buildShimmer(BuildContext ctx) => Center(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: double.infinity,
            height: AppDimensions.screenHeight * .25,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      );

  Widget _buildShimmerImage() => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: double.infinity,
          height: AppDimensions.screenHeight * .20,
          color: Colors.white,
        ),
      );

  Widget _fallbackImage() => Container(
        width: double.infinity,
        height: AppDimensions.screenHeight * .20,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/images/header.jpeg',
            width: double.infinity,
            height: AppDimensions.screenHeight * .20,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) {
              return Center(
                child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade400, size: 40),
              );
            },
          ),
        ),
      );

  Widget _buildFallback(BuildContext ctx) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
          child: _fallbackImage(),
        ),
      );
}
