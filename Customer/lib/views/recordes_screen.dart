import 'package:get/get.dart';
import 'package:biadgo/constants/app_dimensions.dart';
import 'package:flutter/material.dart';

class RecordesScreen extends StatelessWidget {
  const RecordesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            children: [
              Container(
                height: AppDimensions.screenHeight * 0.10,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  // border: Border.all(color: Colors.grey.shade400, width: 1),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: AppDimensions.paddingMedium,
                    left: AppDimensions.paddingMedium,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.south_west,
                            size: 20,
                            color: Get.theme.primaryColor,
                          ),
                          const SizedBox(width: AppDimensions.paddingMedium),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "عمولة طلبية رقم 12#",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(
                                  height: AppDimensions.paddingSmall),
                              Text(
                                "28 يناير , 2025 , 12:00 ص",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        "-10 د.ل",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Get.theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(
                thickness: 1,
                indent: AppDimensions.paddingMedium,
                endIndent: AppDimensions.paddingMedium,
              ),
              Container(
                height: AppDimensions.screenHeight * 0.10,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  // border: Border.all(color: Colors.grey.shade400, width: 1),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: AppDimensions.paddingMedium,
                    left: AppDimensions.paddingMedium,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.north_east,
                            size: 20,
                            color: Get.theme.primaryColor,
                          ),
                          const SizedBox(width: AppDimensions.paddingMedium),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "عمولة طلبية رقم 12#",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(
                                  height: AppDimensions.paddingSmall),
                              Text(
                                "28 يناير , 2025 , 12:00 ص",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        "+10 د.ل",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Get.theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(
                thickness: 1,
                indent: AppDimensions.paddingMedium,
                endIndent: AppDimensions.paddingMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
