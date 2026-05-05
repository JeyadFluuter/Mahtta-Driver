import 'package:biadgo/models/view_messages_model.dart';
import 'package:biadgo/services/view_messages_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ViewMessagesController extends GetxController {
  final RxList<ViewMessagesModel> messages = <ViewMessagesModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final int conversationId;
  int currentPage = 1;
  bool hasMore = true;

  ViewMessagesController({required this.conversationId});

  @override
  void onInit() {
    super.onInit();
    loadMessages();
  }

  Future<void> loadMessages({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage = 1;
        hasMore = true;
        messages.clear();
      }

      if (!hasMore) return;

      isLoading(true);
      errorMessage('');

      final newMessages = await ViewMessagesServices().viewMessages(
        conversationId: conversationId,
        page: currentPage,
      );

      if (newMessages.isEmpty) {
        hasMore = false;
        if (currentPage == 1) {
          errorMessage('لا توجد رسائل متاحة');
        }
      } else {
        messages.addAll(newMessages);
        currentPage++;
      }
    } catch (e) {
      errorMessage('حدث خطأ أثناء جلب الرسائل: ${e.toString()}');
      debugPrint('Error loading messages: $e');
    } finally {
      isLoading(false);
      update();
    }
  }

  Future<void> refreshMessages() async {
    await loadMessages(refresh: true);
  }
}
