import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piaggio_driver/logic/controller/all_shipmetn_types_signUp_controller.dart';
import 'package:piaggio_driver/logic/controller/me_controller.dart';
import 'package:piaggio_driver/model/login_model.dart';
import 'package:piaggio_driver/services/auth_services.dart';
import 'package:piaggio_driver/services/order_request_services.dart';
import 'package:piaggio_driver/views/choose_zoon_maps_screen.dart';
import 'package:piaggio_driver/views/home_screen.dart';
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/routes/routes.dart';
class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final loginfromKey = GlobalKey<FormState>();
  final loginfromKey2 = GlobalKey<FormState>();
  final loginfromKey3 = GlobalKey<FormState>();
  final loginfromKey4 = GlobalKey<FormState>();
  final signupfromKey = GlobalKey<FormState>();
  final GetStorage getStorage = GetStorage();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController passwordConfirmCtrl = TextEditingController();
  final TextEditingController licenseTypeCtrl = TextEditingController();
  final TextEditingController licenseExpiryCtrl = TextEditingController();
  final TextEditingController passportNumberCtrl = TextEditingController();
  final TextEditingController passportExpiryCtrl = TextEditingController();
  final TextEditingController licenseNumberCtrl = TextEditingController();
  RegExp phoneNumberPattern = RegExp(r'^(091|092|093|094)\d{7}$');
   final TextEditingController inviterPhoneCtrl = TextEditingController();
  final RxBool showInviterField = false.obs;

  var isLoading = false.obs;
  var isPasswordHidden = true.obs;
  var loginResponse = Rxn<LoginResponse>();
  final isRegisterLoading = false.obs;

  var errorMessage = ''.obs;
  String? token;
  int? id;
  var phonecache = ''.obs;
  var firstnamecache = ''.obs;
  var lastnamecache = ''.obs;
  var email = ''.obs;
  var images = ''.obs;
  var status = ''.obs;
  var agree = false.obs;

  Rx<File?> licenseFrontImage = Rx<File?>(null);
  Rx<File?> licenseBackImage = Rx<File?>(null);
  Rx<File?> passportFrontImage = Rx<File?>(null);
  Rx<File?> driverImage = Rx<File?>(null);

  Future<void> captureLicenseFrontImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 800, maxHeight: 800);
    if (pickedFile != null) {
      licenseFrontImage.value = File(pickedFile.path);
      debugPrint("تم التقاط صورة الرخصة من الأمام: ${pickedFile.path}");
    }
  }

  Future<void> captureLicenseBackImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 800, maxHeight: 800);
    if (pickedFile != null) {
      licenseBackImage.value = File(pickedFile.path);
      debugPrint("تم التقاط صورة الرخصة من الخلف: ${pickedFile.path}");
    }
  }

  Future<void> capturePassportFrontImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 800, maxHeight: 800);
    if (pickedFile != null) {
      passportFrontImage.value = File(pickedFile.path);
      debugPrint("تم التقاط صورة الجواز من الأمام: ${pickedFile.path}");
    }
  }

  Future<void> captureDriverImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 800, maxHeight: 800);
    if (pickedFile != null) {
      driverImage.value = File(pickedFile.path);
      debugPrint("تم التقاط صورةالسائق  : ${pickedFile.path}");
    }
  }

  Future<String?> checkPhoneAvailability(String phone) async {
    try {
      final res = await http.post(
        Uri.parse('$apiUrl/check-phone'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phone}),
      ).timeout(const Duration(seconds: 40));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['exists'] == true || data['is_registered'] == true) {
          return "رقم الهاتف مسجل مسبقاً، يرجى تسجيل الدخول أو استخدام رقم آخر";
        }
        return null;
      } else if (res.statusCode == 422) {
        final data = jsonDecode(res.body);
        return _translateError(data['message'] ?? "رقم الهاتف غير متاح");
      }
      return null;
    } catch (e) {
      return _translateError(e.toString());
    }
  }

  Future<String?> checkEmailAvailability(String email) async {
    try {
      final res = await http.post(
        Uri.parse('$apiUrl/check-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['exists'] == true || data['is_registered'] == true) {
          return "البريد الإلكتروني مسجل مسبقاً، يرجى استخدام بريد آخر";
        }
        return null;
      } else if (res.statusCode == 422) {
        final data = jsonDecode(res.body);
        return _translateError(data['message'] ?? "البريد الإلكتروني غير متاح");
      }
      return null;
    } catch (e) {
      return _translateError(e.toString());
    }
  }

  String _translateError(String error) {
    final lower = error.toLowerCase();
    
    // Check for network errors first to avoid showing URLs
    if (lower.contains('socketexception') || 
        lower.contains('failed host lookup') || 
        lower.contains('clientexception') ||
        lower.contains('connection failed')) {
      return 'مشكلة في الإنترنت، يرجى المحاولة مرة أخرى';
    }
    
    if (lower.contains('timeoutexception') || lower.contains('timeout')) {
      return 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى';
    }

    if (lower.contains('phone') && lower.contains('taken')) {
      return 'رقم الهاتف مستخدم مسبقاً.';
    }
    if (lower.contains('email') && lower.contains('taken')) {
      return 'البريد الإلكتروني مستخدم مسبقاً.';
    }
    if (lower.contains('credentials') || lower.contains('invalid')) {
      return 'البيانات المدخلة غير صحيحة.';
    }
    if (lower.contains('inviter_phone') || lower.contains('inviter phone')) {
      return 'رقم هاتف الداعي غير موجود في النظام، يرجى التحقق منه أو تركه فارغاً.';
    }
    if (lower.contains('not found')) {
      return 'الحساب غير موجود.';
    }
    
    // Default fallback without internal details
    if (lower.contains('exception') || lower.contains('error')) {
      return 'حدث خطأ أثناء المعالجة، يرجى المحاولة لاحقاً';
    }
    
    return error;
  }

  Future<String?> registerUser({
    required String firstName,
    required String lastName,
    required String licenseNumber,
    required String phone,
    required String email,
    required String password,
    required String passwordConfirm,
    required String licenseType,
    required String licenseExpiry,
    required String passportNumber,
    required String passportExpiry,
    String? inviterPhone,
  }) async {
    bool isValidate = signupfromKey.currentState!.validate();
    if (!isValidate) {
      return "يرجى التحقق من صحة البيانات";
    }
    final shipCtrl = Get.find<AllShipmentTypesSignupController>();
    final ids = shipCtrl.selectedIds;
    try {
      isLoading(true);
      errorMessage.value = '';

      String base64LicenseFront = "";
      String base64LicenseBack = "";
      String base64PassportFront = "";
      String base64DriverImage = "";

      String licenseFrontName = "";
      String licenseBackName = "";
      String passportFrontName = "";
      String driverImageName = "";

      if (licenseFrontImage.value != null) {
        base64LicenseFront = 'data:image/jpeg;base64,' +
            base64Encode(licenseFrontImage.value!.readAsBytesSync());
        licenseFrontName = licenseFrontImage.value!.path.split('/').last;
      }
      if (licenseBackImage.value != null) {
        base64LicenseBack = 'data:image/jpeg;base64,' +
            base64Encode(licenseBackImage.value!.readAsBytesSync());
        licenseBackName = licenseBackImage.value!.path.split('/').last;
      }
      if (passportFrontImage.value != null) {
        base64PassportFront = 'data:image/jpeg;base64,' +
            base64Encode(passportFrontImage.value!.readAsBytesSync());
        passportFrontName = passportFrontImage.value!.path.split('/').last;
      }
      if (driverImage.value != null) {
        base64DriverImage = 'data:image/jpeg;base64,' + 
            base64Encode(driverImage.value!.readAsBytesSync());
        driverImageName = driverImage.value!.path.split('/').last;
      }

      debugPrint("📸 Images sizes (Base64):");
      debugPrint("- Driver Image: ${base64DriverImage.length}");
      debugPrint("- License Front: ${base64LicenseFront.length}");
      debugPrint("- License Back: ${base64LicenseBack.length}");
      debugPrint("- Passport: ${base64PassportFront.length}");

      final result = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        licenseNumber: licenseNumber,
        phone: phone,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirm,
        licenseType: licenseType,
        licenseExpiry: licenseExpiry,
        passportNumber: passportNumber,
        passportExpiry: passportExpiry,
        inviterPhone: inviterPhone,
        driverImageName: driverImageName,
        driverImageData: base64DriverImage,
        passportImageName: passportFrontName,
        passportImageData: base64PassportFront,
        licenseFrontImageName: licenseFrontName,
        licenseFrontImageData: base64LicenseFront,
        licenseBackImageName: licenseBackName,
        licenseBackImageData: base64LicenseBack,
        preferredShipmentTypeIds: ids,
      );

      if (result != null) {
        loginResponse.value = result;
        return null;
      } else {
        return 'فشل في التسجيل. تحقق من البيانات.';
      }
    } catch (e) {
      if (e is http.Response) {
        try {
          final data = jsonDecode(e.body);
          if (data['errors'] != null) {
            Map<String, dynamic> errors = data['errors'];
            List<String> messages = [];
            errors.forEach((key, value) {
              if (value is List) {
                messages.addAll(value.map((e) => _translateError(e.toString())));
              } else {
                messages.add(_translateError(value.toString()));
              }
            });
            return messages.join("\n");
          }
          return _translateError(data['message'] ?? "حدث خطأ غير متوقع");
        } catch (_) {
          return "فشل الاتصال بالسيرفر";
        }
      }
      return 'حدث خطأ: $e';
    } finally {
      isLoading(false);
    }
  }

  double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return null;
      return double.tryParse(s);
    }
    return double.tryParse(v.toString());
  }

  Future<void> loginUser({
    required String phone,
    required String password,
  }) async {
    bool isValidate = loginfromKey.currentState!.validate();
    if (!isValidate) return;
    try {
      isLoading(true);
      errorMessage.value = '';
      final result = await _authService.login(phone: phone, password: password);
      if (result != null) {
        id = result.data.customer.id;
        getStorage.write('id', id);
        token = result.data.token;
        getStorage.write('token', token);
        final meCtrl = Get.find<MeController>();
        await meCtrl.refreshMe();
        debugPrint('تم تسجيل الدخول بنجاح: ${meCtrl.firstname.value}');
        if (Get.isRegistered<PusherService>()) {
          try {
            await Get.find<PusherService>().reconnectWithNewToken();
          } catch (e) {
            debugPrint('Pusher reconnect error: $e');
          }
        } else {
          final svc = Get.put<PusherService>(PusherService(), permanent: true);
          await svc.ensureConnected();
        }

        // التحقق مما إذا كان السائق مفعل (Verified) أولاً
        if (result.data.customer.isVerified == 0) {
          debugPrint("⚠️ السائق غير مفعل - الانتقال لواجهة OTP");
          phonecache.value = phone;
          getStorage.write('phonecache', phone);
          getStorage.write('from_login_flow', true); // علامة للتمييز
          await sendOtp(phone: phone);
          Get.toNamed(AppRoutes.otpSignup);
          return;
        }

        final lat = _asDouble(result.data.customer.currentLat);
        final lng = _asDouble(result.data.customer.currentLng);
        
        if (lat == null || lng == null) {
          Get.offAll(() => const SelectZoneMap());
        } else {
          Get.offAll(() => HomeScreen());
        }
      }
    } catch (e) {
      debugPrint('Login error: $e');
      final err = e.toString();
      
      // اكتشاف حالة الحساب غير المفعل
      if (err == 'UNVERIFIED_ACCOUNT' || 
          err.contains('UNVERIFIED') ||
          err.contains('غير مُفع') ||
          err.contains('تفعيل')) {
        debugPrint("⚠️ السائق غير مفعل (من catch) - الانتقال لواجهة OTP");
        phonecache.value = phone;
        getStorage.write('phonecache', phone);
        getStorage.write('from_login_flow', true); // علامة للتمييز بين التسجيل وتسجيل الدخول
        await sendOtp(phone: phone);
        Get.toNamed(AppRoutes.otpSignup);
        return;
      }
      
      errorMessage.value = _translateError(err.replaceAll('Exception: ', ''));
    } finally {
      isLoading(false);
    }
  }

  Future<String?> sendOtp({required String phone}) async {
    try {
      isLoading(true);
      final result = await _authService.sendOtp(phone: phone);
      if (result) {
        return null;
      } else {
        return "فشل إرسال رمز التحقق";
      }
    } catch (e) {
      return "حدث خطأ أثناء إرسال الرمز: $e";
    } finally {
      isLoading(false);
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }
}
