import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:piaggio_driver/logic/controller/driver_vehicle_data_controller.dart';
import 'package:piaggio_driver/views/home_screen.dart';
import 'package:piaggio_driver/views/vehicle_data.dart';
import 'package:piaggio_driver/views/vehicle_photo.dart';
import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:piaggio_driver/widgets/button.dart';
import '../constants/app_dimensions.dart';

class StepVehicles extends StatefulWidget {
  const StepVehicles({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationStepperState createState() => _RegistrationStepperState();
}

class _RegistrationStepperState extends State<StepVehicles> {
  final PageController _pageController = PageController();

  int _currentStep = 0;
  final int _totalSteps = 2;

  final DriverVehicleDataController controller =
      Get.put(DriverVehicleDataController());

  Future<void> _nextPage() async {
    debugPrint("===> _nextPage called, currentStep = $_currentStep");

    if (_currentStep == 0) {
      final isValid =
          controller.signupfromKey.currentState?.validate() ?? false;
      if (!isValid) {
        Get.snackbar("بيانات المركبة", "هناك خطأ في البيانات");
        return;
      }

      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == _totalSteps - 1) {
      final isPhotoValid =
          controller.signupfromKey2.currentState?.validate() ?? false;
      if (!isPhotoValid) {
        Get.snackbar("خطأ في الصور", "الرجاء رفع جميع الصور المطلوبة");
        return;
      }
      await controller.driverVehicleData(
        vehicleType: "",
        plateNumber: controller.plateNumberCtrl.text,
        chassisNumber: controller.chassisNumberCtrl.text,
        vehicleBoard: controller.vehicleModelCtrl.text,
        vehicleColor: controller.vehicleColorCtrl.text,
        vehicleBrochure: controller.vehicleModelCtrl.text,
        model: controller.vehicleModelCtrl.text,
        capacity: controller.capacityCtrl.text,
      );
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.light.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.paddingSmall),
              child: Image.asset(
                'assets/images/Asset 3.png',
                height: AppDimensions.screenHeight * 0.20,
                width: AppDimensions.screenWidth,
              ),
            ),
            // Modern Progress Bar
            Container(
              height: 6,
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppThemes.primaryNavy.withOpacity(0.05),
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: (MediaQuery.of(context).size.width - (AppDimensions.paddingMedium * 2)) * 
                           ((_currentStep + 1) / _totalSteps),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          AppThemes.primaryOrange,
                          AppThemes.primaryOrange.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  VehicleData(),
                  VehiclePhoto(),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
              child: Obx(() {
                final loading = controller.isLoading.value;
                return Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        flex: 1,
                        child: TextButton(
                          onPressed: _previousPage,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back, size: 18, color: AppThemes.primaryNavy.withOpacity(0.6)),
                              const SizedBox(width: 4),
                              Text(
                                "السابق",
                                style: TextStyle(
                                  color: AppThemes.primaryNavy.withOpacity(0.6),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Button(
                        name: _currentStep == _totalSteps - 1
                            ? 'إرسال البيانات'
                            : "استمرار",
                        isLoading: loading,
                        onPressed: _nextPage,
                        size: Size(double.infinity, AppDimensions.buttonHeight),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    ),
   );
  }
}
