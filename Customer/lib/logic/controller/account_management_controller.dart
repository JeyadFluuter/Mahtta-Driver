import 'package:biadgo/routes/routes.dart';
import 'package:biadgo/services/auth_services.dart';
import 'package:biadgo/services/order_accepted_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'refresh_token_controller.dart';

class AccountManagementController extends GetxController {
  final AuthService _authService = AuthService();
  final GetStorage _storage = GetStorage();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    errorMessage.value = '';
  }

  Future<bool> deleteAccount(String password) async {
    errorMessage.value = '';
    isLoading.value = true;
    try {
      final String? token = _storage.read('token');
      if (token == null || token.isEmpty) {
        errorMessage.value = 'جلسة العمل منتهية، يرجى تسجيل الدخول مرة أخرى';
        return false;
      }

      final bool success = await _authService.deleteAccount(token: token);

      if (success) {
        await _localSignOut();
        Get.offAllNamed(AppRoutes.welcomeScreen);
        return true;
      }
      return false;
    } catch (e) {
      final String errorMsg = e.toString();
      debugPrint('❌ Delete Account Exception: $errorMsg');
      
      if (errorMsg.contains('401') || 
          errorMsg.toLowerCase().contains('unauthenticated') || 
          errorMsg.contains('تسجيل الدخول')) {
        
        debugPrint('🔄 Token invalid/expired, attempting to refresh...');
        final refreshTokenController = Get.find<RefreshTokenController>();
        final newToken = await refreshTokenController.refreshNow();
        
        if (newToken != null) {
          debugPrint('✅ Token refreshed, retrying deletion...');
          try {
            final bool success = await _authService.deleteAccount(token: newToken);
            if (success) {
              await _localSignOut();
              Get.offAllNamed(AppRoutes.welcomeScreen);
              return true;
            }
          } catch (retryError) {
            errorMessage.value = retryError.toString();
          }
        } else {
          errorMessage.value = 'انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى';
        }
      } else {
        errorMessage.value = errorMsg;
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _localSignOut() async {
    try {
      await OrderAcceptedServices().dispose();
    } catch (_) {}
    await _storage.erase();
  }
}
