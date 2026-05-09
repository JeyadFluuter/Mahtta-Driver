import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/services/add_balance_services.dart';
import 'package:piaggio_driver/logic/controller/wallet_controller.dart';

class AddBalanceController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = "".obs;
  var successMessage = "".obs;
  
  final addbalance = GlobalKey<FormState>();
  final AddBalanceServices _addBalance = AddBalanceServices();
  final TextEditingController addBalanceController = TextEditingController();

  Future<void> addBalance({required String code}) async {
    final isValidate = addbalance.currentState!.validate();
    if (!isValidate) return;

    try {
      isLoading(true);
      errorMessage("");
      successMessage("");
      
      final result = await _addBalance.addBalance(code: code);
      if (result != null && result is Map) {
        if (Get.isRegistered<WalletController>()) {
          await Get.find<WalletController>().fetchData();
        }
        addBalanceController.clear();
        
        final msg = result['message'] ?? "تم شحن الرصيد بنجاح";
        successMessage(msg);
      }
    } catch (e) {
      debugPrint("Caught error in controller: $e");
      try {
        final errorData = jsonDecode(e.toString());
        
        // Extract message for 422 or logic errors
        final msg = errorData['message'] ?? "حدث خطأ ما، يرجى المحاولة لاحقاً";
        errorMessage(msg);
      } catch (_) {
        errorMessage("فشل الاتصال بالخادم");
      }
    } finally {
      isLoading(false);
    }
  }
}
