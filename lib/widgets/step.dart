import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:piaggio_driver/routes/routes.dart';
import 'package:piaggio_driver/views/Auth/User_SignUp/user_SignUp4.dart';
import 'package:piaggio_driver/views/Auth/User_SignUp/user_SignUp5.dart';
import 'package:piaggio_driver/views/Auth/User_SignUp/user_signUp1.dart';
import 'package:piaggio_driver/views/Auth/User_SignUp/user_signUp2.dart';
import 'package:piaggio_driver/views/Auth/User_SignUp/insert_Phone_SignUp_screen.dart';
import 'package:piaggio_driver/views/Auth/User_SignUp/otp_SignUp_screen.dart';
import '../constants/app_dimensions.dart';
import '../logic/controller/auth_controller.dart';
import 'package:piaggio_driver/widgets/button.dart';


class RegistrationStepper extends StatefulWidget {
  const RegistrationStepper({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationStepperState createState() => _RegistrationStepperState();
}

class _RegistrationStepperState extends State<RegistrationStepper> {
  final PageController _pageController = PageController();

  int _currentStep = 0;
  final int _totalSteps = 5;

  final AuthController controller = Get.put(AuthController());

  final RxString _errorMessage = "".obs;

  Future<void> _nextPage() async {
    debugPrint("===> _nextPage called, currentStep = $_currentStep");
    _errorMessage.value = "";

    if (_currentStep == 0) {
      final isValid = controller.loginfromKey.currentState?.validate() ?? false;
      if (!isValid) {
        _errorMessage.value = "هناك خطأ في البيانات";
        return;
      }

      try {
        controller.isRegisterLoading.value = true;
        final emailError = await controller.checkEmailAvailability(controller.emailCtrl.text.trim());
        if (emailError != null) {
          _errorMessage.value = emailError;
          return;
        }
      } catch (e) {
        debugPrint("Email check error: $e");
      } finally {
        controller.isRegisterLoading.value = false;
      }

      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == 1) {
      final isValid2 =
          controller.loginfromKey2.currentState?.validate() ?? false;
      if (!isValid2) {
        _errorMessage.value = "هناك خطأ في البيانات (الصفحة الثانية)";
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
    } else if (_currentStep == 2) {
      final isValid3 =
          controller.loginfromKey3.currentState?.validate() ?? false;
      if (!isValid3) {
        _errorMessage.value = "هناك خطأ في البيانات (الصفحة الثالثة)";
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
    } else if (_currentStep == 3) {
      final isValid4 =
          controller.loginfromKey4.currentState?.validate() ?? false;
      if (!isValid4) {
        _errorMessage.value = "هناك خطأ في البيانات (الصفحة الرابعة)";
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
      final isPhoneValid =
          controller.signupfromKey.currentState?.validate() ?? false;
      if (!isPhoneValid) {
        _errorMessage.value = "رقم الهاتف غير صحيح";
        return;
      }
      try {
        controller.isRegisterLoading.value = true;
        
        // 1. Check if phone is already registered
        final phoneError = await controller.checkPhoneAvailability(controller.phoneCtrl.text.trim());
        if (phoneError != null) {
          _errorMessage.value = phoneError;
          return;
        }

        // 2. Proceed with registration
        final result = await controller.registerUser(
          firstName: controller.nameCtrl.text.trim(),
          lastName: controller.lastNameCtrl.text.trim(),
          licenseNumber: controller.licenseNumberCtrl.text.trim(),
          phone: controller.phoneCtrl.text.trim(),
          email: controller.emailCtrl.text.trim(),
          password: controller.passwordCtrl.text.trim(),
          passwordConfirm: controller.passwordConfirmCtrl.text.trim(),
          licenseType: controller.licenseTypeCtrl.text.trim(),
          licenseExpiry: controller.licenseExpiryCtrl.text.trim(),
          passportNumber: controller.passportNumberCtrl.text.trim(),
          passportExpiry: controller.passportExpiryCtrl.text.trim(),
          inviterPhone: controller.inviterPhoneCtrl.text.trim(),
        );

        if (result == null) {
          Get.toNamed(AppRoutes.otpSignup);
        } else {
          _errorMessage.value = result;
        }
      } catch (e) {
        _errorMessage.value = "صار خطأ أثناء الإرسال، حاول مرة ثانية";
      } finally {
        controller.isRegisterLoading.value = false;
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.paddingSmall),
                child: Image.asset(
                  'assets/images/piaggio22.png',
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
                    UserSignup1(),
                    UserSignup2(),
                    UserSignup4(),
                    UserSignup5(),
                    InsertPhoneSignupScreen(),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              Obx(() => _errorMessage.value.isNotEmpty
                  ? Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE), // Light red background
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFCDD2)), // Red border
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage.value,
                              style: TextStyle(
                                  color: AppThemes.primaryNavy.withOpacity(0.4),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink()),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
                child: Obx(() {
                  final isLoading = controller.isRegisterLoading.value;
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
                          isLoading: isLoading,
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
