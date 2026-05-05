import 'package:biadgo/logic/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:biadgo/constants/app_theme.dart';
import 'package:biadgo/widgets/city_autocomplete_field.dart';

class UserSignup1 extends StatelessWidget {
  UserSignup1({super.key});

  final AuthController controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    debugPrint("UserSignup1 Controller HashCode: ${controller.hashCode}");
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Form(
          key: controller.signupfromKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "البيانات الأساسية",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.primaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "يرجى إدخال اسمك الحقيقي واختيار صورة شخصية",
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 25),
              Center(
                child: Stack(
                  children: [
                    Obx(() => Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade100,
                            border: Border.all(color: Get.theme.primaryColor.withOpacity(0.2), width: 2),
                            image: controller.image.value != null
                                ? DecorationImage(
                                    image: FileImage(controller.image.value!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: controller.image.value == null
                              ? Icon(Icons.person_outline, size: 50, color: Colors.grey.shade400)
                              : null,
                        )),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => controller.captureImage(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Get.theme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              _buildTextField(
                "الاسم الأول",
                icon: Icons.person_outline,
                controller: controller.nameCtrl,
                validator: (value) => value == null || value.isEmpty ? "يرجى إدخال الاسم الأول" : null,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                "اللقب (الاسم الأخير)",
                icon: Icons.person_outline,
                controller: controller.lastNameCtrl,
                validator: (value) => value == null || value.isEmpty ? "يرجى إدخال الاسم الأخير" : null,
              ),
              const SizedBox(height: 15),
              CityAutocompleteField(
                hint: "المدينة",
                icon: Icons.location_city_outlined,
                controller: controller.cityCtrl,
                validator: (value) => value == null || value.isEmpty ? "يرجى إدخال المدينة" : null,
                borderRadius: 12,
                iconSize: 20,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    required TextEditingController controller,
    required String? Function(String?) validator,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      textAlign: TextAlign.right,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      ),
      cursorColor: Get.theme.primaryColor,
    );
  }
}
