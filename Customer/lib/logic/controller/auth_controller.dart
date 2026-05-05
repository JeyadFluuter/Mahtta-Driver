import 'dart:convert';
import 'dart:io';
import 'package:biadgo/logic/controller/me_controller.dart';
import 'package:biadgo/logic/controller/refresh_token_controller.dart';
import 'package:biadgo/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/login_model.dart';
import '../../services/auth_services.dart';

import 'forgot_password_controller.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final loginfromKey = GlobalKey<FormState>();
  final signupfromKey = GlobalKey<FormState>();
  final termsFormKey = GlobalKey<FormState>();
  final GetStorage getStorage = GetStorage();
  RegExp phoneNumberPattern = RegExp(r'^(091|092|093|094)\d{7}$');
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController cityCtrl = TextEditingController();
  final TextEditingController passwordConfirmCtrl = TextEditingController();
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var isLoading = false.obs;
  var loginResponse = Rxn<LoginResponse>();
  var errorMessage = ''.obs;
  var phoneErrorMessage = ''.obs;
  var emailErrorMessage = ''.obs;
  var successMessage = ''.obs;
  String? token;
  String? refreshToken;
  String? accessExpires;
  String? phonecache;
  String? firstnamecache;
  String? lastnamecache;
  String? city;
  String? email;
  int? id;
  Rx<File?> image = Rx<File?>(null);
  var agree = false.obs;

  Future<void> captureImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image.value = File(pickedFile.path);
      debugPrint("تم التقاط صورة المستخدم: ${pickedFile.path}");
    }
  }

  Future<String?> registerUser({
    required String firstName,
    required String lastName,
    required String city,
    required String phone,
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    bool isValidate = termsFormKey.currentState!.validate();
    if (!isValidate) {
      return "يرجى التحقق من صحة البيانات";
    }
    try {
      isLoading(true);
      errorMessage.value = '';
      phoneErrorMessage.value = '';
      emailErrorMessage.value = '';

      String base64image = "";
      if (image.value != null) {
        base64image = base64Encode(image.value!.readAsBytesSync());
      }

      final result = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        city: city,
        phone: phone,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirm,
        image: base64image,
      );

      if (result != null) {
        firstnamecache = result.data.customer.firstName;
        getStorage.write('firstnamecache', firstnamecache);
        lastnamecache = result.data.customer.lastName;
        getStorage.write('lastnamecache', lastnamecache);
        phonecache = result.data.customer.phone;
        phoneCtrl.text = phonecache ?? "";
        getStorage.write('phonecache', phonecache);

        loginResponse.value = result;
        return null;
      } else {
        return "فشل في التسجيل. تحقق من البيانات.";
      }
    } catch (e) {
      String raw = e.toString();
      if (raw.startsWith('Exception: ')) {
        raw = raw.substring(11);
      }
      
      try {
        final Map<String, dynamic> errorData = jsonDecode(raw);
        if (errorData['errors'] != null) {
          final Map<String, dynamic> errors = errorData['errors'];
          List<String> messages = [];
          errors.forEach((key, value) {
            if (value is List) {
              messages.addAll(value.map((e) => e.toString()));
            } else {
              messages.add(value.toString());
            }
          });
          return messages.join("\n");
        } else {
          return errorData['message'] ?? "حدث خطأ غير متوقع.";
        }
      } catch (_) {
        return raw.isNotEmpty ? raw : "حدث خطأ، يرجى المحاولة في وقت لاحق.";
      }
    } finally {
      isLoading(false);
    }
  }

  // دالة لتسجيل الدخول (Login)
  Future<void> loginUser({
    required String phone,
    required String password,
  }) async {
    bool isValidate = loginfromKey.currentState!.validate();
    if (!isValidate) {
      return;
    }

    try {
      isLoading(true);
      errorMessage.value = '';

      final result = await _authService.login(
        phone: phone,
        password: password,
      );

      if (result != null) {
        id = result.data.customer.id;
        getStorage.write('id', id);
        accessExpires = result.data.accessExpires;
        getStorage.write('accessExpires', accessExpires);

        refreshToken = result.data.refreshToken;
        getStorage.write('refreshToken', refreshToken);

        token = result.data.token;
        getStorage.write('token', token);

        final meCtrl = Get.find<MeController>();
        await meCtrl.meUser();

        Get.find<RefreshTokenController>().reschedule();
        if (Get.overlayContext != null) {
          Get.snackbar("تسجيل الدخول", "عملية تسجيل الدخول صحيحة",
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
              icon: const Icon(Icons.check));
        }
        loginResponse.value = result;
        isLoading(false);

        // التحقق مما إذا كان المستخدم مفعل (Verified)
        if (result.data.customer.isVerified == 0) {
          debugPrint("المستخدم غير مفعل - الانتقال لواجهة OTP");

          // حفظ البيانات في الكاش
          phonecache = result.data.customer.phone;
          getStorage.write('phonecache', phonecache);
          phoneCtrl.text = phonecache ?? "";

          // إرسال الرمز تلقائياً
          final forgotCtrl = Get.put(ForgotPasswordController());
          final bool successfulResend = await forgotCtrl.resendOtp(phone: phonecache!);

          if (successfulResend) {
            Get.toNamed(AppRoutes.otpSignup);
          }
          return;
        }

        Get.offAllNamed(AppRoutes.navbar);
      }
    } catch (e) {
      debugPrint("خطأ في loginUser: $e");
      isLoading(false);

      if (e.toString() == 'UNVERIFIED_ACCOUNT') {
        errorMessage.value = "لم يتم التحقق من الحساب، يرجى تفعيل الحساب أولاً.";
        // حفظ البيانات في الكاش للانتقال لصفحة OTP
        phonecache = phoneCtrl.text.trim();
        getStorage.write('phonecache', phonecache);

        // إرسال الرمز تلقائياً
        final forgotCtrl = Get.put(ForgotPasswordController());
        final bool successfulResend = await forgotCtrl.resendOtp(phone: phonecache!);

        if (successfulResend) {
          Get.toNamed(AppRoutes.otpSignup);
        }
        return;
      }

      errorMessage.value = e.toString();
    } finally {
      isLoading(false);
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }
}
