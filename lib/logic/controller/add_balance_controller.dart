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
        
        // Use ONLY message from server for success
        successMessage(result['message'] ?? "");
      }
    } catch (e) {
      debugPrint("Caught error in controller: $e");
      try {
        final errorData = jsonDecode(e.toString());
        
        // Use ONLY 'message' field from server for errors
        if (errorData['message'] != null) {
          errorMessage(errorData['message']);
        } else {
          errorMessage("حدث خطأ ما، يرجى المحاولة لاحقاً");
        }
      } catch (_) {
        errorMessage("فشل الاتصال بالخادم");
      }
    } finally {
      isLoading(false);
    }
  }
}
