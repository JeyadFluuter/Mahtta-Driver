import 'dart:convert';
import 'dart:io';
import 'package:biadgo/logic/controller/me_controller.dart';
import 'package:biadgo/models/update_profile_model.dart';
import 'package:biadgo/services/update_profile_services.dart';
import 'package:biadgo/widgets/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfileController extends GetxController {
  final updateprofilefromKey = GlobalKey<FormState>();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController firstnameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController cityCtrl = TextEditingController();
  var updateProfile = Rxn<UpdateProfile>();
  var isLoading = false.obs;
  
  Rx<File?> selectedImage = Rx<File?>(null);

  Future<void> chooseImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
      debugPrint("تم اختيار صورة جديدة: ${pickedFile.path}");
    }
  }

  Future<void> updateProfilee({
    required String firstName,
    required String lastName,
    required String city,
    required String email,
  }) async {
    bool isValidate = updateprofilefromKey.currentState!.validate();
    if (!isValidate) {
      return;
    }
    try {
      isLoading.value = true;
      String? base64image;
      if (selectedImage.value != null) {
        base64image = base64Encode(selectedImage.value!.readAsBytesSync());
      }

      final result = await UpdateProfileServices().updateresponse(
        firstName: firstName,
        lastName: lastName,
        city: city,
        email: email,
        image: base64image,
      );

      if (result != null) {
        await Get.find<MeController>().meUser();
        Get.offAll(NavBar());
        Get.snackbar("تعديل بيانات الحساب", "تم تعديل بيانات الحساب بنجاح",
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            icon: const Icon(Icons.check));
        updateProfile.value = result;
      }
 else {
        Get.snackbar(
            "فشل في تعديل بيانات الحساب. تحقق من البيانات وحاول مرة أخرى",
            "هناك خطأ في عملية تعديل بيانات الحساب",
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            icon: const Icon(Icons.error));
      }
    } catch (e) {
      debugPrint("خطأ أثناء تعديل بيانات الحساب: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
