import 'package:biadgo/logic/controller/account_management_controller.dart';
import 'package:biadgo/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeleteAccountDialog extends StatelessWidget {
  DeleteAccountDialog({super.key});

  final AccountManagementController controller =
      Get.put(AccountManagementController());
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _contentBox(context),
      ),
    );
  }

  Widget _contentBox(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(
              left: 20, top: 60, right: 20, bottom: 20),
          margin: const EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 10),
                blurRadius: 20,
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  "حذف الحساب نهائياً",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "نأسف لرؤيتك ترحل! هل أنت متأكد من رغبتك في حذف حسابك؟ سيؤدي هذا الإجراء إلى فقدان كافة بياناتك وطلباتك المخزنة.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'أدخل كلمة المرور للتأكيد',
                    suffixIcon: const Icon(Icons.lock_outline, size: 20),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال كلمة المرور';
                    }
                    return null;
                  },
                ),
                Obx(() => controller.errorMessage.value.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          controller.errorMessage.value,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink()),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => TextButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    controller.errorMessage.value = '';
                                    Navigator.of(context).pop();
                                  },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'تراجع',
                              style: TextStyle(
                                color: controller.isLoading.value
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade500,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => Button(
                            name: 'حذف الحساب',
                            isLoading: controller.isLoading.value,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                controller
                                    .deleteAccount(passwordController.text);
                              }
                            },
                            size: const Size(double.infinity, 50),
                            // ملاحظة: قمت بتعديل البوتن برمجياً ليدعم اللون الأحمر إذا لزم، 
                            // لكن هنا سنعتمد على التصميم القياسي للبوتن مع Get.theme.primaryColor 
                            // أو نغير التصميم يدوياً إذا كان البوتن يدعم تغيير اللون.
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
              radius: 40,
              child: Icon(
                Icons.warning_amber_rounded,
                color: Get.theme.primaryColor,
                size: 45,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
