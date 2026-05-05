import 'package:biadgo/views/termes_policies.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../logic/controller/auth_controller.dart';
import 'package:biadgo/constants/app_theme.dart';

class InsertPhoneSignupScreen extends StatelessWidget {
  InsertPhoneSignupScreen({super.key});
  final AuthController controllerr = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    debugPrint("InsertPhoneSignupScreen Controller HashCode: ${controllerr.hashCode}");
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Form(
          key: controllerr.termsFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "معلومات الحساب",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.primaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "أدخل تفاصيل الاتصال وكلمة المرور لتأمين حسابك",
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              // General Error Message (e.g. 500 error)
              Obx(() {
                if (controllerr.errorMessage.isEmpty) return const SizedBox.shrink();
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    controllerr.errorMessage.value,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                );
              }),
              const SizedBox(height: 15),
              _buildLabel("رقم الهاتف"),
              _buildTextField(
                "09X XXXXXXX",
                icon: Icons.phone_android,
                controller: controllerr.phoneCtrl,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return "الرجاء إدخال رقم الهاتف";
                  if (!controllerr.phoneNumberPattern.hasMatch(value)) return "رقم هاتف غير صحيح";
                  return null;
                },
              ),
              Obx(() => _buildErrorLabel(controllerr.phoneErrorMessage.value)),
              const SizedBox(height: 15),
              _buildLabel("البريد الإلكتروني"),
              _buildTextField(
                "example@mail.com",
                icon: Icons.email_outlined,
                controller: controllerr.emailCtrl,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return "الرجاء إدخال البريد الإلكتروني";
                  if (!GetUtils.isEmail(value)) return "بريد إلكتروني غير صالح";
                  return null;
                },
              ),
              Obx(() => _buildErrorLabel(controllerr.emailErrorMessage.value)),
              const SizedBox(height: 15),
              _buildLabel("كلمة المرور"),
              _buildPasswordField(
                "كلمة المرور",
                controller: controllerr.passwordCtrl,
                isHidden: controllerr.isPasswordHidden,
                onToggle: controllerr.togglePasswordVisibility,
                validator: (value) {
                  if (value == null || value.isEmpty) return "الرجاء إدخال كلمة المرور";
                  if (value.length < 6) return "كلمة المرور قصيرة جداً";
                  return null;
                },
              ),
              const SizedBox(height: 15),
              _buildLabel("تأكيد كلمة المرور"),
              _buildPasswordField(
                "أعد كتابة كلمة المرور",
                controller: controllerr.passwordConfirmCtrl,
                isHidden: controllerr.isConfirmPasswordHidden,
                onToggle: controllerr.toggleConfirmPasswordVisibility,
                validator: (value) {
                  if (value == null || value.isEmpty) return "الرجاء تأكيد كلمة المرور";
                  if (value != controllerr.passwordCtrl.text) return "كلمة المرور غير متطابقة";
                  return null;
                },
              ),
              const SizedBox(height: 25),
              _buildTermsSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppThemes.primaryNavy),
      ),
    );
  }

  Widget _buildErrorLabel(String error) {
    if (error.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 5, right: 4),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 14),
          const SizedBox(width: 5),
          Text(error, style: const TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    required TextEditingController controller,
    required String? Function(String?) validator,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      style: const TextStyle(fontSize: 15),
      decoration: _inputDecoration(hint, icon),
      cursorColor: Get.theme.primaryColor,
    );
  }

  Widget _buildPasswordField(
    String hint, {
    required TextEditingController controller,
    required RxBool isHidden,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return Obx(() => TextFormField(
          controller: controller,
          validator: validator,
          obscureText: isHidden.value,
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 15),
          decoration: _inputDecoration(hint, Icons.lock_outline).copyWith(
            suffixIcon: IconButton(
              icon: Icon(isHidden.value ? Icons.visibility_off : Icons.visibility, color: Colors.grey.shade400, size: 18),
              onPressed: onToggle,
            ),
          ),
          cursorColor: Get.theme.primaryColor,
        ));
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Get.theme.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  Widget _buildTermsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Get.to(() => const TermesPolicies()),
            child: Text(
              "الشروط والسياسات",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Get.theme.primaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const Text(" أوافق على ", style: TextStyle(fontSize: 13)),
          Obx(() => Checkbox(
                value: controllerr.agree.value,
                onChanged: (v) => controllerr.agree.value = v ?? false,
                activeColor: Get.theme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              )),
        ],
      ),
    );
  }
}
