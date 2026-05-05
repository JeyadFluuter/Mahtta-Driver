import 'package:biadgo/models/change_phone_model.dart';
import 'package:biadgo/services/change_phone_services.dart';
import 'package:biadgo/views/Auth/otp_change_phone_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ChangePhoneController extends GetxController {
  final ChangePhoneServices changePhoneServices = ChangePhoneServices();

  final changephonefromKey = GlobalKey<FormState>();
  final GetStorage getStorage = GetStorage();
  final TextEditingController phoneCtrl = TextEditingController();
  RegExp phoneNumberPattern = RegExp(r'^(091|092|093|094)\d{7}$');
  var changePhone = Rxn<ChangePhoneModel>();
  String? phonecachee;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> ChangePhone({required String phone}) async {
    errorMessage.value = '';
    bool isValidate = changephonefromKey.currentState!.validate();
    if (!isValidate) return;

    try {
      isLoading.value = true;
      debugPrint("🚀 الرقم المدخل: $phone");
      final result = await changePhoneServices.changePhone(phone: phone);

      if (result != null) {
        phonecachee = result.phone;
        phoneCtrl.text = phone;
        getStorage.write('phonecache', phonecachee);
        debugPrint(
            "✅ تم تخزين الرقم في GetStorage: ${getStorage.read('phonecache')}");

        Get.snackbar("إرسال رمز تحقق", "تم إرسال رمز التحقق بنجاح",
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            icon: const Icon(Icons.check));
        Get.to(() => OtpChangePhoneScreen());
      } else {
        // إذا كان هناك خطأ (مثل الرقم مأخوذ مسبقاً)
        errorMessage.value = "هذا الرقم مسجل مسبقاً لمستخدم آخر";
        Get.snackbar("إرسال رمز تحقق", "فشلت عملية إرسال رمز التحقق",
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            icon: const Icon(Icons.error));
      }
    } catch (e) {
      debugPrint("❌ خطأ أثناء تغيير الرقم: $e");
      errorMessage.value = "حدث خطأ أثناء الاتصال بالسيرفر";
    } finally {
      isLoading.value = false;
    }
  }
}
