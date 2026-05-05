import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:piaggio_driver/logic/controller/auth_controller.dart';
import 'package:piaggio_driver/views/terms_policies_screen.dart';

class InsertPhoneSignupScreen extends StatelessWidget {
  InsertPhoneSignupScreen({super.key});
  final AuthController controllerr = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Form(
        key: controllerr.signupfromKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
              bottom: 80), // Extra space for keyboard and footer
          child: Column(children: [
            const SizedBox(height: 20),
            Text(
              'التأكد من رقم الهاتف',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppThemes.primaryNavy,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'سنرسل لك رمز تحقق (OTP) للتأكد من ملكيتك لهذا الرقم وإكمال عملية التسجيل',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 30),
            //
            TextFormField(
              textAlign: TextAlign.right,
              controller: controllerr.phoneCtrl,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "الرجاء إدخال رقم الهاتف";
                }
                if (value.length < 9) {
                  return " رقم الهاتف أقل من 9 أرقام";
                }
                if (!value.contains(controllerr.phoneNumberPattern)) {
                  return "الرجاء إدخال رقم هاتف صحيح";
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'رقم الهاتف',
                hintStyle: TextStyle(color: AppThemes.primaryNavy.withOpacity(0.4), fontSize: 13),
                prefixIcon: Icon(Icons.phone_android_outlined,
                    color: AppThemes.primaryNavy.withOpacity(0.4), size: 20),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppThemes.primaryNavy.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppThemes.primaryOrange, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
              ),
            ),
            const SizedBox(
              height: AppDimensions.paddingMediumX,
            ),
            FormField<bool>(
              initialValue: controllerr.agree.value,
              validator: (value) {
                if (value != true) {
                  return 'يجب الموافقة على الشروط وسياسات الخصوصية للمتابعة';
                }
                return null;
              },
              builder: (state) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      textDirection: TextDirection.rtl,
                      children: [
                        Obx(() => Checkbox(
                              value: controllerr.agree.value,
                              onChanged: (newValue) {
                                controllerr.agree.value = newValue ?? false;
                                state.didChange(controllerr.agree.value);
                              },
                              checkColor: Colors.white,
                              activeColor: AppThemes.primaryOrange,
                              side: BorderSide(color: AppThemes.primaryNavy.withOpacity(0.2)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            )),
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              text: 'أوافق على ',
                              style: TextStyle(
                                  color: AppThemes.primaryNavy.withOpacity(0.6), fontSize: 13),
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: InkWell(
                                    onTap: () => Get.to(
                                        () => const TermsPoliciesScreen()),
                                    child: Text(
                                      'الشروط وسياسات الخصوصية',
                                      style: TextStyle(
                                        color: AppThemes.primaryOrange,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          state.errorText!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                );
              },
            ),
          ]),
        ),
      ),
    );
  }
}
