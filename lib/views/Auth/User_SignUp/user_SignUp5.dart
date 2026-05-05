// ignore: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:piaggio_driver/logic/controller/auth_controller.dart';

class UserSignup5 extends StatelessWidget {
  UserSignup5({super.key});

  final AuthController controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingSmall),
        child: Form(
          key: controller.loginfromKey4,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.paddingLarge),
                _buildImageUpload(
                  title: "صورة الرخصة من الامام",
                  obsValue: controller.licenseFrontImage,
                  onTap: () => controller.captureLicenseFrontImage(),
                  validator: (value) => controller.licenseFrontImage.value == null
                      ? 'يرجى رفع صورة الرخصة من الامام   '
                      : null,
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                _buildImageUpload(
                  title: "صورة الرخصة من الخلف",
                  obsValue: controller.licenseBackImage,
                  onTap: () => controller.captureLicenseBackImage(),
                  validator: (value) => controller.licenseBackImage.value == null
                      ? 'يرجى رفع صورة الرخصة من الخلف   '
                      : null,
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                _buildImageUpload(
                  title: "صورة الجواز",
                  obsValue: controller.passportFrontImage,
                  onTap: () => controller.capturePassportFrontImage(),
                  validator: (value) => controller.passportFrontImage.value == null
                      ? 'يرجى رفع صورة الجواز   '
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageUpload({
    required String title,
    required dynamic obsValue,
    required Function onTap,
    required String? Function(bool?) validator,
  }) {
    return FormField<bool>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              await onTap();
              state.validate();
            },
            child: Obx(() => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppThemes.primaryNavy.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: obsValue.value != null
                          ? Colors.green
                          : AppThemes.primaryNavy.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      _iconCircle(filled: obsValue.value != null),
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
                )),
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 8),
              child: Text(
                state.errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
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
          color: filled ? Colors.green.withOpacity(0.1) : Colors.white),
      child: Icon(
        filled ? Icons.check_circle : Icons.camera_alt_outlined,
        color: filled ? Colors.green : AppThemes.primaryNavy.withOpacity(0.5),
        size: 20,
      ),
    );
  }
}
