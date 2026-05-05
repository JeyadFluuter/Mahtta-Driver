import 'package:biadgo/logic/controller/change_phone_controller.dart';
import 'package:biadgo/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePhoneScreen extends StatelessWidget {
  ChangePhoneScreen({super.key});
  final ChangePhoneController controllerr =
      Get.put(ChangePhoneController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("تغيير رقم الهاتف"),
          centerTitle: true,
          backgroundColor: Get.theme.primaryColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.grey.shade100,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Form(
                  key: controllerr.changephonefromKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ادخل رقم هاتفك الجديد وسنرسل لك رمز تحقق لمساعدتك علي إتمام العملية.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'رقم الهاتف الجديد',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        textAlign: TextAlign.right,
                        controller: controllerr.phoneCtrl,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "الرجاء إدخال رقم الهاتف";
                          }
                          if (value.length < 9) {
                            return "رقم الهاتف أقل من 9 أرقام";
                          }
                          if (!value.contains(controllerr.phoneNumberPattern)) {
                            return "الرجاء إدخال رقم هاتف صحيح";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'مثال: 0910000000',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          suffixIcon: Icon(
                            Icons.phone_android_outlined,
                            color: Get.theme.primaryColor.withOpacity(0.7),
                            size: 22,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Get.theme.primaryColor, width: 1.5),
                          ),
                          errorStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Obx(() => controllerr.errorMessage.value.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                              child: Text(
                                controllerr.errorMessage.value,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : const SizedBox.shrink()),
                      const SizedBox(height: 48),
                      Center(
                        child: Obx(() => Button(
                          name: 'إرسال رمز التحقق',
                          isLoading: controllerr.isLoading.value,
                          onPressed: () {
                            if (controllerr.changephonefromKey.currentState!.validate()) {
                              controllerr.ChangePhone(
                                phone: controllerr.phoneCtrl.text.trim(),
                              );
                            }
                          },
                          size: const Size(double.infinity, 56),
                        )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
