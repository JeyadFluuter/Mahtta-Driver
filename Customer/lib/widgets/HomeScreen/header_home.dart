import 'package:biadgo/constants/app_dimensions.dart';
import 'package:biadgo/logic/controller/me_controller.dart';
import 'package:biadgo/logic/controller/my_order_controller.dart';
import 'package:biadgo/models/my_order_model.dart';
import 'package:biadgo/views/save_location_screen.dart';
import 'package:biadgo/widgets/ribbon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'image_slider.dart';
import 'package:biadgo/constants/app_theme.dart';

class HeaderHome extends StatelessWidget {
  HeaderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppDimensions.paddingSmall),
        const ImageSliderScreen(),
        const SizedBox(height: AppDimensions.paddingMedium),
        Padding(
          padding: const EdgeInsets.only(right: AppDimensions.paddingSmall),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              "اطلب شحنة الآن ",
              style: TextStyle(
                color: AppThemes.primaryNavy,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
      ],
    );
  }
}
