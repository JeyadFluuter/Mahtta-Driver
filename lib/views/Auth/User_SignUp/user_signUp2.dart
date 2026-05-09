// ignore: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:piaggio_driver/logic/controller/auth_controller.dart';
import 'package:piaggio_driver/widgets/searchable_dropdown.dart';

class UserSignup2 extends StatelessWidget {
  UserSignup2({super.key});

  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingSmall),
        child: Form(
          key: controller.loginfromKey2,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppDimensions.paddingLarge),
                _buildTextField(
                  "رقم الرخصة",
                  ctrl: controller.licenseNumberCtrl,
                  icon: Icons.badge_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "يرجى إدخال رقم الرخصة";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                SearchableDropdown<String>(
                  hint: "نوع الرخصة",
                  icon: Icons.category_outlined,
                  value: controller.licenseTypeCtrl.text.isNotEmpty ? controller.licenseTypeCtrl.text : null,
                  items: const ['أولى', 'ثانية', 'ثالثة', 'رابعة'],
                  itemAsString: (val) => val,
                  onChanged: (val) {
                    if (val != null) controller.licenseTypeCtrl.text = val;
                  },
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "يرجى إدخال نوع الرخصة";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                _buildTextField(
                  "تاريخ إنتهاء الرخصة",
                  ctrl: controller.licenseExpiryCtrl,
                  icon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: Get.context!,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppThemes.primaryOrange,
                              onPrimary: Colors.white,
                              onSurface: AppThemes.primaryNavy,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: AppThemes.primaryOrange,
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (pickedDate != null) {
                      controller.licenseExpiryCtrl.text =
                          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "يرجى إدخال تاريخ إنتهاء الرخصة";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                _buildTextField(
                  "رقم جواز السفر",
                  ctrl: controller.passportNumberCtrl,
                  icon: Icons.airplane_ticket_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "يرجى إدخال رقم جواز السفر";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                _buildTextField(
                  "تاريخ إنتهاء الجواز",
                  ctrl: controller.passportExpiryCtrl,
                  icon: Icons.calendar_month_outlined,
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: Get.context!,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppThemes.primaryOrange,
                              onPrimary: Colors.white,
                              onSurface: AppThemes.primaryNavy,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: AppThemes.primaryOrange,
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (pickedDate != null) {
                      controller.passportExpiryCtrl.text =
                          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "يرجى إدخال تاريخ إنتهاء الجواز";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    bool isPassword = false,
    bool readOnly = false,
    required IconData icon,
    VoidCallback? onTap,
    required TextEditingController ctrl,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      obscureText: isPassword,
      controller: ctrl,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      textAlign: TextAlign.right,
      keyboardType: (hint.contains("رقم") && !hint.contains("جواز") && !hint.contains("الرخصة"))
          ? TextInputType.number
          : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppThemes.primaryNavy.withOpacity(0.4), fontSize: 13),
        prefixIcon: Icon(icon, color: AppThemes.primaryNavy.withOpacity(0.4), size: 20),
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
          borderSide: const BorderSide(color: AppThemes.primaryOrange, width: 1.5),
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
    );
  }
}
