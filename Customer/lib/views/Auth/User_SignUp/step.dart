import 'package:biadgo/views/Auth/User_SignUp/insert_phone_signUp_screen.dart';
import 'package:biadgo/routes/routes.dart';
import 'package:get/get.dart';
import 'package:biadgo/views/Auth/User_SignUp/user_signUp1.dart';
import 'package:biadgo/constants/app_theme.dart';
import 'package:flutter/material.dart';
import '../../../constants/app_dimensions.dart';
import '../../../logic/controller/auth_controller.dart';

class RegistrationStepper extends StatefulWidget {
  const RegistrationStepper({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationStepperState createState() => _RegistrationStepperState();
}

class _RegistrationStepperState extends State<RegistrationStepper> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 2;

  final AuthController controller = Get.put(AuthController());

  final RxString _errorMessage = "".obs;

  Future<void> _nextPage() async {
    _errorMessage.value = "";
    if (_currentStep == 0) {
      final isValid =
          controller.signupfromKey.currentState?.validate() ?? false;
      if (!isValid) return;

      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == _totalSteps - 1) {
      final isStep2Valid =
          controller.termsFormKey.currentState?.validate() ?? false;
      if (!isStep2Valid) return;

      if (!controller.agree.value) {
        _errorMessage.value = "يجب الموافقة على الشروط والسياسات للمتابعة";
        return;
      }

      final error = await controller.registerUser(
        firstName: controller.nameCtrl.text.trim(),
        lastName: controller.lastNameCtrl.text.trim(),
        city: controller.cityCtrl.text.trim(),
        phone: controller.phoneCtrl.text.trim(),
        email: controller.emailCtrl.text.trim(),
        password: controller.passwordCtrl.text.trim(),
        passwordConfirm: controller.passwordConfirmCtrl.text.trim(),
      );
      if (error == null) {
        Get.toNamed(AppRoutes.otpSignup);
      } else {
        _errorMessage.value = error;
      }
    }
  }

  void _previousPage() {
    _errorMessage.value = "";
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: _currentStep > 0 ? _previousPage : () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: AppThemes.primaryNavy, size: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/mahtta22.png',
                  height: AppDimensions.screenHeight * 0.10,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                // Progress Bar
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade100,
                  ),
                  child: Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: MediaQuery.of(context).size.width * ((_currentStep + 1) / _totalSteps),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Get.theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                const SizedBox(height: 25),
                // Dynamic content switching to allow for dynamic height (important for error labels)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _currentStep == 0
                      ? UserSignup1(key: const ValueKey(0))
                      : InsertPhoneSignupScreen(key: const ValueKey(1)),
                ),
                const SizedBox(height: 10),
                Obx(() => _errorMessage.value.isNotEmpty
                    ? Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage.value,
                                style: TextStyle(
                                    color: Colors.red.shade900,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink()),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Obx(() => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Get.theme.primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          fixedSize: Size(AppDimensions.screenWidth * 0.9, 55),
                        ),
                        onPressed: controller.isLoading.value ? null : _nextPage,
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                _currentStep == _totalSteps - 1 ? 'إرسال رمز التحقق' : 'المتابعة',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
