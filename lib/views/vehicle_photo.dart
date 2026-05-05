import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/logic/controller/driver_vehicle_data_controller.dart';
import 'package:piaggio_driver/constants/app_theme.dart';

class VehiclePhoto extends StatelessWidget {
  VehiclePhoto({super.key});

  final DriverVehicleDataController controller =
      Get.find<DriverVehicleDataController>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.signupfromKey2,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppDimensions.paddingSmall),
                    PhotoPickField(
                      title: "صورة وثيقة التأمين",
                      imageRx: controller.documentImage,
                      onPick: controller.captureDocumentImage,
                      validatorMessage: "يرجى رفع وثيقة التأمين",
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    PhotoPickField(
                      title: "صورة السيارة من الأمام",
                      imageRx: controller.vehicleFrontImage,
                      onPick: controller.captureVehicleFrontImage,
                      validatorMessage: "يرجى رفع صورة السيارة من الأمام",
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    PhotoPickField(
                      title: "صورة السيارة من الخلف",
                      imageRx: controller.vehicleBackImage,
                      onPick: controller.captureVehicleBackImage,
                      validatorMessage: "يرجى رفع صورة السيارة من الخلف",
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    PhotoPickField(
                      title: "صورة السيارة من اليمين",
                      imageRx: controller.vehicleRightImage,
                      onPick: controller.captureVehicleRightImage,
                      validatorMessage: "يرجى رفع صورة السيارة من اليمين",
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    PhotoPickField(
                      title: "صورة السيارة من اليسار",
                      imageRx: controller.vehicleLeftImage,
                      onPick: controller.captureVehicleLeftImage,
                      validatorMessage: "يرجى رفع صورة السيارة من اليسار",
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    PhotoPickField(
                      title: "صورة السيارة من الداخل",
                      imageRx: controller.vehicleInsideImage,
                      onPick: controller.captureVehicleInsideImage,
                      validatorMessage: "يرجى رفع صورة السيارة من الداخل",
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    PhotoPickField(
                      title: "صورة السيارة من الصندوق",
                      imageRx: controller.vehicleTrunkImage,
                      onPick: controller.captureVehicleTrunkImage,
                      validatorMessage: "يرجى رفع صورة السيارة من الصندوق",
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                  ],
                ),
              ),
            );
  }
}

class PhotoPickField extends StatelessWidget {
  const PhotoPickField({
    super.key,
    required this.title,
    required this.imageRx,
    required this.onPick,
    required this.validatorMessage,
  });

  final String title;
  final Rx<File?> imageRx;
  final Future<void> Function() onPick;
  final String validatorMessage;

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (_) => imageRx.value == null ? validatorMessage : null,
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final filled = imageRx.value != null;

            return GestureDetector(
              onTap: () async {
                await onPick();
                state.validate();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                decoration: BoxDecoration(
                  color: AppThemes.primaryNavy.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: filled
                        ? Colors.green
                        : AppThemes.primaryNavy.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    _iconCircle(filled: filled),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Text(
                      title,
                      style: TextStyle(
                        color: AppThemes.primaryNavy,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 8),
              child: Text(
                state.errorText!,
                style: TextStyle(color: AppThemes.light.colorScheme.error, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _iconCircle({required bool filled}) {
    return Container(
      width: AppDimensions.screenHeight * .04,
      height: AppDimensions.screenHeight * .04,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? Colors.green.withOpacity(0.1) : Colors.white,
      ),
      child: Icon(
        filled ? Icons.check_circle : Icons.camera_alt_outlined,
        color: filled ? Colors.green : AppThemes.primaryNavy.withOpacity(0.5),
        size: 20,
      ),
    );
  }
}
