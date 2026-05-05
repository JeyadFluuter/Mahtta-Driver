import 'package:flutter/material.dart';
import 'package:piaggio_driver/constants/app_theme.dart';
import '../constants/app_dimensions.dart';

// ignore: must_be_immutable
class Button extends StatelessWidget {
  final String name;
  final Function() onPressed;
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
          backgroundColor: AppThemes.primaryOrange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
          fixedSize: size),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading) ...[
            const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
