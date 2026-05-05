import 'package:biadgo/constants/app_dimensions.dart';
import 'package:biadgo/logic/controller/me_controller.dart';
import 'package:biadgo/logic/controller/update_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:biadgo/constants/app_theme.dart';

import '../widgets/button.dart';
import '../widgets/city_autocomplete_field.dart';

class ProfileDetails extends StatefulWidget {
  const ProfileDetails({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<ProfileDetails> {
  final UpdateProfileController controller = Get.put(UpdateProfileController());
  final MeController meController = Get.put(MeController());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("تعديل بيانات الحساب", style: TextStyle(color: AppThemes.primaryNavy, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: AppThemes.primaryNavy),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: controller.updateprofilefromKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "تحديث البيانات الشخصية",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppThemes.primaryNavy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "يمكنك تعديل اسمك ومدينتك وبريدك الإلكتروني من هنا",
                  style: const TextStyle(fontSize: 13, color: AppThemes.primaryNavy),
                ),
                const SizedBox(height: 25),
                Center(
                  child: Stack(
                    children: [
                      Obx(() => Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade100,
                              border: Border.all(
                                  color: Get.theme.primaryColor.withOpacity(0.2),
                                  width: 2),
                              image: controller.selectedImage.value != null
                                  ? DecorationImage(
                                      image: FileImage(
                                          controller.selectedImage.value!),
                                      fit: BoxFit.cover,
                                    )
                                  : (meController.image.value.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(
                                              meController.image.value),
                                          fit: BoxFit.cover,
                                        )
                                      : const DecorationImage(
                                          image: AssetImage(
                                              "assets/images/profile2.png"),
                                          fit: BoxFit.cover,
                                        )),
                            ),
                          )),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => controller.chooseImage(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Get.theme.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                _buildTextField(
                  "الاسم الأول",
                  icon: Icons.person_outline,
                  controller: controller.firstnameCtrl
                    ..text = meController.firstname.value,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  "اللقب (الاسم الأخير)",
                  icon: Icons.person_outline,
                  controller: controller.lastNameCtrl
                    ..text = meController.lastname.value,
                ),
                const SizedBox(height: 15),
                CityAutocompleteField(
                  hint: "المدينة",
                  icon: Icons.location_city_outlined,
                  controller: controller.cityCtrl
                    ..text = meController.city.value,
                  borderRadius: 15,
                  iconSize: 22,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  "البريد الإلكتروني",
                  icon: Icons.email_outlined,
                  controller: controller.emailCtrl
                    ..text = meController.email.value,
                ),
                const SizedBox(height: 35),
                Center(
                  child: Obx(() => Button(
                        name: 'حفظ التعديلات',
                        isLoading: controller.isLoading.value,
                        onPressed: () {
                          controller.updateProfilee(
                            firstName: controller.firstnameCtrl.text.trim(),
                            lastName: controller.lastNameCtrl.text.trim(),
                            city: controller.cityCtrl.text.trim(),
                            email: controller.emailCtrl.text.trim(),
                          );
                        },
                        size: Size(
                          AppDimensions.screenWidth * 0.7,
                          AppDimensions.buttonHeight,
                        ),
                      )),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    required TextEditingController controller,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 22),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Get.theme.primaryColor, width: 1.5),
        ),
      ),
      cursorColor: Get.theme.primaryColor,
    );
  }
}
