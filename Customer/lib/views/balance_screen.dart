import 'package:get/get.dart';
import 'package:biadgo/constants/app_dimensions.dart';
import 'package:biadgo/widgets/button.dart';
import 'package:flutter/material.dart';

class BalanceScreen extends StatelessWidget {
  const BalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
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
          TextFormField(
            // controller: controller.phoneCtrl,
            textAlign: TextAlign.right,
            // validator: (value) {
            //   if (value!.isEmpty) {
            //     return "الرجاء إدخال رقم الهاتف";
            //   }
            //   if (value.length < 9) {
            //     return " رقم الهاتف أقل من 9 أرقام";
            //   }
            //   if (!value.contains(controller.phoneNumberPattern)) {
            //     return "الرجاء إدخال رقم هاتف صحيح";
            //   }
            //   return null;
            // },
            decoration: InputDecoration(
              focusColor: Get.theme.primaryColor,
              hintText: 'XXX-XXXX-XXX',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Get.theme.primaryColor, width: 1),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingLarge,
                horizontal: AppDimensions.paddingMedium,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Center(
            child: Button(
              name: 'تأكيد',
              onPressed: () {},
              size: Size(
                AppDimensions.screenWidth * 0.5,
                AppDimensions.buttonHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
