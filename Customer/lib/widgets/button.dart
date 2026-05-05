import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';

// ignore: must_be_immutable
class Button extends StatelessWidget {
  final String name;
  final VoidCallback? onPressed;
  final Size size;
  final bool isLoading;

  const Button({
    super.key,
    required this.name,
    required this.onPressed,
    required this.size,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: Get.theme.primaryColor.withValues(alpha: 0.6),
        backgroundColor: Get.theme.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        ),
        fixedSize: size,
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}

