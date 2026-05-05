import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/logic/controller/add_balance_controller.dart';
import 'package:piaggio_driver/widgets/button.dart';

class BalanceScreen extends StatelessWidget {
  BalanceScreen({super.key});
  final AddBalanceController controller = Get.put(AddBalanceController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "الرجاء إدخال رقم الكرت :",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Form(
              key: controller.addbalance,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رقم الكرت  ';
                  }
                  return null;
                },
                controller: controller.addBalanceController,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.black),
                cursorColor: AppThemes.primaryOrange,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  focusColor: AppThemes.primaryOrange,
                  hintText: 'XXX-XXXX-XXX',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: AppThemes.primaryOrange,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: AppThemes.primaryOrange,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: AppThemes.primaryOrange,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppThemes.primaryOrange.withValues(alpha: .1),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingMedium,
                    horizontal: AppDimensions.paddingMedium,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Obx(() => controller.errorMessage.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      controller.errorMessage.value,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  )
                : const SizedBox.shrink()),
            Obx(() => controller.successMessage.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      controller.successMessage.value,
                      style: const TextStyle(color: Colors.green, fontSize: 13),
                    ),
                  )
                : const SizedBox.shrink()),
            const SizedBox(height: AppDimensions.paddingSmall),
            Center(
              child: Button(
                name: 'تأكيد',
                onPressed: () {
                  controller.addBalance(
                    code: controller.addBalanceController.text,
                  );
                },
                size: Size(
                  AppDimensions.screenWidth * 0.5,
                  AppDimensions.buttonHeight,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 40),
          ],
        ),
      ),
    );
  }
}
