import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/logic/controller/driver_vehicle_data_controller.dart';
import 'package:piaggio_driver/logic/controller/vehicle_type_controller.dart';
import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:shimmer/shimmer.dart';
import 'package:piaggio_driver/widgets/searchable_dropdown.dart';
import 'package:piaggio_driver/model/vehicle_type_model.dart';

class VehicleData extends StatelessWidget {
  VehicleData({super.key});

  final DriverVehicleDataController ctrl = Get.find();
  final VehicleCategoryController catCtrl = Get.put(VehicleCategoryController());

  final List<String> _brands = [
    'تويوتا (Toyota)', 'هيونداي (Hyundai)', 'كيا (Kia)', 'نيسان (Nissan)',
    'فورد (Ford)', 'شيفروليه (Chevrolet)', 'بيادجو (Piaggio)',
    'مرسيدس (Mercedes)', 'بي إم دبليو (BMW)', 'هوندا (Honda)',
    'ميتسوبيشي (Mitsubishi)', 'مازدا (Mazda)', 'سوزوكي (Suzuki)',
    'فولكس فاجن (Volkswagen)', 'أودي (Audi)', 'جي إم سي (GMC)',
    'لكزس (Lexus)', 'لاند روفر (Land Rover)', 'بيجو (Peugeot)', 'رينو (Renault)', 'أخرى'
  ];

  final List<String> _colors = [
    'أبيض', 'أسود', 'فضي', 'رمادي', 'أحمر', 'أزرق', 'أخضر', 'بني', 'بيج', 'أصفر', 'برتقالي', 'أخرى'
  ];

  final List<String> _capacities = [
    '4 ركاب', '5 ركاب', '7 ركاب', 'أقل من 1 طن', '1 طن', '1.5 طن', '2 طن', '2.5 طن', '3 طن', '4 طن', '5 طن', 'أكثر من 5 طن', 'أخرى'
  ];

  final List<String> _models = List.generate(
      DateTime.now().year - 1990 + 2, (index) => (1990 + index).toString()).reversed.toList();

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
            
            // Vehicle Category
            Obx(() {
              if (catCtrl.isLoading.value) {
                return _buildSkeletonDropdown();
              }
              final cats = catCtrl.categories;
              final selectedCat = cats.firstWhereOrNull((c) => c.id == catCtrl.selectedCategoryId.value);
              
              return SearchableDropdown<VehicleCategory>(
                hint: 'فئة المركبة',
                icon: Icons.category_outlined,
                value: selectedCat,
                items: cats,
                itemAsString: (c) => c.name ?? '',
                onChanged: (val) {
                  if (val != null) {
                    catCtrl.selectCategory(val.id!);
                    ctrl.selectedVehicleId(0); // Reset vehicle when category changes
                  }
                },
                validator: (val) {
                  if (val == null || val.id == 0) {
                    return 'يرجى اختيار فئة المركبة';
                  }
                  return null;
                },
              );
            }),
            const SizedBox(height: AppDimensions.paddingMedium),
            
            // Vehicle Type
            Obx(() {
              if (catCtrl.isLoading.value) {
                return _buildSkeletonDropdown();
              }
              final vehicles = catCtrl.getVehiclesForSelectedCategory();
              final selectedVeh = vehicles.firstWhereOrNull((v) => v.id == ctrl.selectedVehicleId.value);
              
              return SearchableDropdown<Vehicle>(
                hint: 'المركبة',
                icon: Icons.directions_car_filled_outlined,
                value: selectedVeh,
                items: vehicles,
                itemAsString: (v) => v.name ?? '',
                onChanged: (val) {
                  if (val != null) {
                    ctrl.selectedVehicleId(val.id!);
                  }
                },
                validator: (val) {
                  if (val == null || val.id == 0) {
                    return 'يرجى اختيار المركبة';
                  }
                  return null;
                },
              );
            }),
            const SizedBox(height: AppDimensions.paddingMedium),
            
            // Plate Number
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
            
            // Chassis Number
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
            
            // Color
            SearchableDropdown<String>(
              hint: "اللون",
              icon: Icons.color_lens_outlined,
              value: ctrl.vehicleColorCtrl.text.isNotEmpty ? ctrl.vehicleColorCtrl.text : null,
              items: _colors,
              itemAsString: (c) => c,
              onChanged: (val) {
                if (val != null) ctrl.vehicleColorCtrl.text = val;
              },
              validator: (val) {
                if (val == null || val.isEmpty) return "يرجى اختيار اللون";
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            
            // Brand
            SearchableDropdown<String>(
              hint: "العلامة التجارية",
              icon: Icons.branding_watermark_outlined,
              value: ctrl.vehicleBrandCtrl.text.isNotEmpty ? ctrl.vehicleBrandCtrl.text : null,
              items: _brands,
              itemAsString: (b) => b,
              onChanged: (val) {
                if (val != null) ctrl.vehicleBrandCtrl.text = val;
              },
              validator: (val) {
                if (val == null || val.isEmpty) return "يرجى اختيار العلامة التجارية";
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            
            // Model
            SearchableDropdown<String>(
              hint: "سنة الموديل",
              icon: Icons.calendar_month_outlined,
              value: ctrl.vehicleModelCtrl.text.isNotEmpty ? ctrl.vehicleModelCtrl.text : null,
              items: _models,
              itemAsString: (m) => m,
              onChanged: (val) {
                if (val != null) ctrl.vehicleModelCtrl.text = val;
              },
              validator: (val) {
                if (val == null || val.isEmpty) return "يرجى اختيار الموديل";
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            
            // Capacity / Weight
            SearchableDropdown<String>(
              hint: "السعة / الوزن",
              icon: Icons.line_weight_outlined,
              value: ctrl.capacityCtrl.text.isNotEmpty ? ctrl.capacityCtrl.text : null,
              items: _capacities,
              itemAsString: (c) => c,
              onChanged: (val) {
                if (val != null) ctrl.capacityCtrl.text = val;
              },
              validator: (val) {
                if (val == null || val.isEmpty) return "يرجى اختيار السعة / الوزن";
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonDropdown() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
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

