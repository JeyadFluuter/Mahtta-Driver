// الصفحة الخاصة ببيانات الشخصية

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:piaggio_driver/logic/controller/auth_controller.dart';

class UserSignup1 extends StatelessWidget {
  UserSignup1({super.key});

  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingSmall),
        child: Form(
          key: controller.loginfromKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppDimensions.paddingMedium),
                FormField<bool>(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (_) => controller.driverImage.value == null
                      ? 'يرجى رفع صورة السائق   '
                      : null,
                  builder: (state) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await controller.captureDriverImage();
                          state.validate();
                        },
                        child: Obx(() => Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(
                                  AppDimensions.paddingSmall),
                              decoration: BoxDecoration(
                                color: AppThemes.primaryNavy.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: controller.driverImage.value != null
                                      ? Colors.green
                                      : AppThemes.primaryNavy.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _iconCircle(
                                      filled:
                                          controller.driverImage.value != null),
                                  const SizedBox(
                                      width: AppDimensions.paddingSmall),
                                  Text(
                                    "صورة السائق  ",
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
                            style: TextStyle(
                                color: AppThemes.light.colorScheme.error, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                _buildTextField("الاسم الأول",
                    ctrl: controller.nameCtrl,
                    icon: Icons.person_outline, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "يرجى إدخال الاسم الأول";
                  }
                  return null;
                }),
                const SizedBox(height: AppDimensions.paddingMedium),
                _buildTextField("اللقب",
                    ctrl: controller.lastNameCtrl,
                    icon: Icons.person_outline,
                    validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "يرجى إدخال اللقب";
                  }
                  return null;
                }),
                const SizedBox(height: AppDimensions.paddingMedium),
                _buildTextField("البريد الإلكتروني",
                    ctrl: controller.emailCtrl,
                    icon: Icons.email_outlined,
                    validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "يرجى إدخال البريد الإلكتروني";
                  }
                  return null;
                }),
                const SizedBox(height: AppDimensions.paddingMedium),
                Obx(() => _buildTextField("كلمة المرور",
                    isPassword: true,
                    ctrl: controller.passwordCtrl,
                    icon: Icons.lock_outline,
                    validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "يرجى إدخال كلمة المرور";
                  }
                  if (value.length < 6) {
                    return "يجب أن تحتوي كلمة المرور على 6 أحرف على الأقل";
                  }
                  return null;
                })),
                const SizedBox(height: AppDimensions.paddingMedium),
                Obx(() => _buildTextField("تأكيد كلمة المرور",
                    isPassword: true,
                    ctrl: controller.passwordConfirmCtrl,
                    icon: Icons.lock_reset_outlined,
                    validator: (value) {
                  if (value == null || value.isEmpty)
                    return "الرجاء إدخال تأكيد كلمة المرور";
                  if (value.length < 6) {
                    return "الرجاء إدخال كلمة مرور تحتوي على أكثر من 6 عناصر";
                  }
                  if (value != controller.passwordCtrl.text) {
                    return "كلمة المرور غير متطابقة";
                  }
                  return null;
                })),
                const SizedBox(height: AppDimensions.paddingMedium),
                // Referral Section (Professional UI/UX Solution)
                _buildReferralSection(),
                const SizedBox(height: AppDimensions.paddingMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReferralSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => controller.showInviterField.value = !controller.showInviterField.value,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: AppThemes.primaryOrange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppThemes.primaryOrange.withOpacity(0.2),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.card_giftcard, size: 18, color: AppThemes.primaryOrange),
                const SizedBox(width: 8),
                Text(
                  "هل تم دعوتك بواسطة صديق؟ (رقم هاتفه)",
                  style: TextStyle(
                    color: AppThemes.primaryOrange,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Obx(() => Icon(
                      controller.showInviterField.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppThemes.primaryOrange,
                    )),
              ],
            ),
          ),
        ),
        Obx(() => AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SizeTransition(sizeFactor: animation, child: child);
              },
              child: controller.showInviterField.value
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: _buildTextField(
                        "رقم هاتف الصديق الذي دعاك",
                        ctrl: controller.inviterPhoneCtrl,
                        icon: Icons.person_add_alt_1_outlined,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!value.contains(controller.phoneNumberPattern)) {
                              return "الرجاء إدخال رقم هاتف صحيح";
                            }
                          }
                          return null;
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
            )),
      ],
    );
  }

  Widget _buildTextField(String hint,
      {bool isPassword = false,
      required IconData icon,
      required TextEditingController ctrl,
      required String? Function(String?) validator}) {
    return TextFormField(
      obscureText: isPassword ? controller.isPasswordHidden.value : false,
      controller: ctrl,
      validator: validator,
      textAlign: TextAlign.right,
      keyboardType: hint.contains("البريد") ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppThemes.primaryNavy.withOpacity(0.4), fontSize: 13),
        prefixIcon: Icon(icon, color: AppThemes.primaryNavy.withOpacity(0.4), size: 20),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: () => controller.togglePasswordVisibility(),
                icon: Icon(
                  controller.isPasswordHidden.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppThemes.primaryNavy.withOpacity(0.4),
                  size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppThemes.primaryNavy.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppThemes.primaryOrange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppThemes.light.colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppThemes.light.colorScheme.error, width: 1.5),
        ),
      ),
    );
  }

  Widget _iconCircle({required bool filled}) {
    return Container(
      width: AppDimensions.screenHeight * .04,
      height: AppDimensions.screenHeight * .04,
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: filled ? Colors.green.withOpacity(0.1) : Colors.white),
      child: Icon(
        filled ? Icons.check_circle : Icons.camera_alt_outlined,
        color: filled ? Colors.green : AppThemes.primaryNavy.withOpacity(0.5),
        size: 20,
      ),
    );
  }
}
