import 'package:biadgo/constants/app_dimensions.dart';
import 'package:biadgo/logic/controller/navbar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:biadgo/constants/app_theme.dart';

class RequestOrder extends StatelessWidget {
  const RequestOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      child: Container(
        width: double.infinity,
        height: AppDimensions.screenHeight * 0.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: AssetImage("assets/images/map.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                       AppThemes.primaryOrange.withValues(alpha: 0.0),
                       AppThemes.primaryOrange.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    bottom: AppDimensions.paddingSmall * 3,
                    right: AppDimensions.paddingSmall * 1.5,
                    left: AppDimensions.paddingSmall * 1.5),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.find<NavBarController>().changeTabIndex(1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemes.primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingSmall * 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "اطلب شحنة",
                           style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        const SizedBox(width: AppDimensions.paddingSmall),
                        Icon(
                          Icons.arrow_forward_ios,
                           color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
