import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/logic/controller/driver_vehicle_data_controller.dart';
import 'package:piaggio_driver/logic/controller/vehicle_type_controller.dart';
import 'package:piaggio_driver/constants/app_theme.dart';

class VehicleData extends StatelessWidget {
  VehicleData({super.key});

  final DriverVehicleDataController ctrl = Get.find();
  final VehicleCategoryController catCtrl =
      Get.put(VehicleCategoryController());

  @override
  Widget build(BuildContext context) {
    return Form(
      key: ctrl.signupfromKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppDimensions.paddingSmall),
                    Obx(() {
                      if (catCtrl.isLoading.value) {
                        return Center(
                            child: CircularProgressIndicator(
                          color: AppThemes.primaryOrange,
                        ));
                      }
                      final cats = catCtrl.categories;
                      return _buildDropdown<int>(
                        hint: 'فئة المركبة',
                        value: catCtrl.selectedCategoryId.value > 0
                            ? catCtrl.selectedCategoryId.value
                            : null,
                        items: cats
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name ?? '',
                                      style: const TextStyle(fontSize: 14)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          catCtrl.selectCategory(val!);
                          ctrl.selectedVehicleId(0);
                        },
                        validator: (val) {
                          if (val == null || val == 0) {
                            return 'يرجى اختيار فئة المركبة';
                          }
                          return null;
                        },
                      );
                    }),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    Obx(() {
                      final vehicles = catCtrl.getVehiclesForSelectedCategory();
                      return _buildDropdown<int>(
                        hint: 'المركبة',
                        value: ctrl.selectedVehicleId.value > 0
                            ? ctrl.selectedVehicleId.value
                            : null,
                        items: vehicles
                            .map((v) => DropdownMenuItem(
                                  value: v.id,
                                  child: Text(v.name ?? '',
                                      style: const TextStyle(fontSize: 14)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          ctrl.selectedVehicleId(val!);
                        },
                        validator: (val) {
                          if (val == null || val == 0) {
                            return 'يرجى اختيار المركبة';
                          }
                          return null;
                        },
                      );
                    }),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    _buildTextField(
                      "رقم اللوحة",
                      icon: Icons.pin_outlined,
                      controller: ctrl.plateNumberCtrl,
                      validator: (v) {
                        if (v == null || v.isEmpty) return "يرجى إدخال رقم اللوحة";
                        if (v.length < 3) return "رقم اللوحة قصير جداً";
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    _buildTextField(
                      "رقم الهيكل (Chassis)",
                      icon: Icons.settings_outlined,
                      controller: ctrl.chassisNumberCtrl,
                      validator: (v) {
                        if (v == null || v.isEmpty) return "يرجى إدخال رقم الهيكل";
                        if (v.length < 5) return "رقم الهيكل غير صحيح";
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    _buildDropdown<String>(
                      hint: "اللون",
                      value: ctrl.vehicleColorCtrl.text.isNotEmpty ? ctrl.vehicleColorCtrl.text : null,
                      items: [
                        'أبيض', 'أسود', 'فضي', 'رمادي', 'أحمر', 'أزرق', 'أخضر', 'بني', 'بيج', 'أصفر', 'برتقالي'
                      ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => ctrl.vehicleColorCtrl.text = val ?? '',
                      validator: (val) {
                        if (val == null || val.isEmpty) return "يرجى اختيار اللون";
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    _buildTextField(
                      "العلامة التجارية",
                      icon: Icons.branding_watermark_outlined,
                      controller: ctrl.vehicleBrandCtrl,
                      validator: (v) {
                        if (v == null || v.isEmpty) return "يرجى إدخال العلامة التجارية";
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    _buildTextField(
                      "الموديل",
                      icon: Icons.directions_car_outlined,
                      controller: ctrl.vehicleModelCtrl,
                      validator: (v) {
                        if (v == null || v.isEmpty) return "يرجى إدخال الموديل";
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    _buildTextField(
                      "السعة / الوزن",
                      icon: Icons.line_weight_outlined,
                      controller: ctrl.capacityCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return "يرجى إدخال السعة";
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    required String? Function(T?) validator,
  }) {
    return DropdownButtonFormField<T>(
      borderRadius: BorderRadius.circular(12),
      value: value,
      icon: Icon(Icons.keyboard_arrow_down, color: AppThemes.primaryNavy.withOpacity(0.4)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppThemes.primaryNavy.withOpacity(0.4), fontSize: 13),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppThemes.primaryNavy.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppThemes.primaryOrange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppThemes.light.colorScheme.error, width: 1),
        ),
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildTextField(
    String hint, {
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppThemes.primaryNavy.withOpacity(0.4), fontSize: 13),
        prefixIcon: Icon(icon, color: AppThemes.primaryNavy.withOpacity(0.4), size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppThemes.primaryNavy.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppThemes.primaryOrange, width: 1.5),
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
}
