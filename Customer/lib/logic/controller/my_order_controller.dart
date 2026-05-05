// ignore_for_file: unreachable_switch_case

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:biadgo/models/my_order_model.dart';
import 'package:biadgo/services/my_order_services.dart';
import 'refresh_token_controller.dart';

class MyOrderController extends GetxController {
  static const int perPage = 15;
  final RxBool hasAcceptedOrder = false.obs;
  final Rxn<MyOrder> latestActiveOrder = Rxn<MyOrder>();
  int? _totalPages;
  late final PagingController<int, MyOrder> pagingController;
  Timer? _refreshTimer;
  int _consecutiveFailures = 0;
  static const int _maxConsecutiveFailures = 3;
  bool _isFetching = false; // منع الطلبات المتزامنة

  @override
  void onInit() {
    super.onInit();

    pagingController = PagingController<int, MyOrder>(
      getNextPageKey: (state) {
        final next = (state.keys?.last ?? 0) + 1;
        if (_totalPages != null && next > _totalPages!) return null;
        return next;
      },
      fetchPage: _fetchPageAndUpdateBadge,
    );
    _prefetchBadgeOnly();
    // نؤخر تحديث الـ pagingController قليلاً لتجنب الطلبات المتزامنة عند البداية
    Future.delayed(const Duration(milliseconds: 500), () {
      pagingController.refresh();
    });

    // نبدأ الـ Timer بعد 3 ثوانٍ لإعطاء الطلبات الأولية وقتاً للإكمال
    Future.delayed(const Duration(seconds: 3), () {
      _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        _prefetchBadgeOnly();
      });
    });
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    pagingController.dispose();
    super.onClose();
  }

  bool _isOngoing(String? s, {int? id}) {
    if (id != null) {
      if (id == 6 || id == 7 || id == 8) return false;
      if (id >= 1 && id <= 5) return true;
    }
    if (s == null || s.isEmpty) return false;
    
    // تعريف الحالات المنتهية (التي لا تعتبر نشطة)
    const terminalStatuses = {
      'تم التوصيل',
      'ملغية',
      'ملغية (قبل القبول)',
      'ملغية (بعد القبول)',
      'مرفوضة',
      'مكتملة',
      'تم الالغاء',
      'تم الإلغاء',
      'Cancelled',
      'Delivered',
    };
    
    // إذا لم تكن الحالة من ضمن الحالات المنتهية، فهي حالة نشطة
    return !terminalStatuses.contains(s);
  }

  Future<bool> checkOngoingOrders() async {
    await _prefetchBadgeOnly();
    return hasAcceptedOrder.value;
  }

  Future<void> _prefetchBadgeOnly() async {
    // منع الطلبات المتزامنة (Connection Pool Exhaustion)
    if (_isFetching) {
      debugPrint('⏭️ prefetchBadgeOnly skipped (already fetching)');
      return;
    }
    // إذا فشل الاتصال أكثر من الحد المسموح، نتوقف مؤقتاً لتجنب إغراق السيرفر
    if (_consecutiveFailures >= _maxConsecutiveFailures) {
      debugPrint('⏸️ prefetchBadgeOnly skipped (too many consecutive failures: $_consecutiveFailures)');
      return;
    }
    _isFetching = true;
    try {
      final res =
          await MyOrderDataServices().myOrderData(page: 1, perPage: perPage);
      final List<MyOrder> items = switch (res) {
        // ignore: pattern_never_matches_value_type
        (List<MyOrder> list, int _) => list,
        List<MyOrder> list => list,
        _ => const <MyOrder>[],
      };

      // نجح الطلب → نصفر العداد
      _consecutiveFailures = 0;

      final active = items.firstWhereOrNull((o) => _isOngoing(o.status?.name, id: o.status?.id));
      debugPrint('🔍 First order status: ${items.isNotEmpty ? items.first.status?.name : "No orders"}');
      debugPrint('🔍 Is ongoing: ${active != null}');
      
      hasAcceptedOrder.value = active != null;
      latestActiveOrder.value = active;
    } catch (e) {
      _consecutiveFailures++;
      debugPrint('❌ Error in prefetchBadgeOnly ($_consecutiveFailures/$_maxConsecutiveFailures): $e');
    } finally {
      _isFetching = false;
    }
  }

  Future<List<MyOrder>> _fetchPageAndUpdateBadge(int page) async {
    final service = MyOrderDataServices();
    try {
      final dynamic res = await service.myOrderData(page: page, perPage: perPage);
      return _handleSuccessfulResponse(res, page);
    } catch (e) {
      if (e.toString().contains('401')) {
        debugPrint('🔄 [Archive] 401 Unified Error, attempting token refresh for page $page...');
        final refreshTokenController = Get.find<RefreshTokenController>();
        final newToken = await refreshTokenController.refreshNow();
        
        if (newToken != null) {
          debugPrint('✅ [Archive] Token refreshed, retrying fetch for page $page...');
          try {
            final dynamic retryRes = await service.myOrderData(page: page, perPage: perPage);
            return _handleSuccessfulResponse(retryRes, page);
          } catch (retryError) {
            debugPrint('❌ [Archive] Retry failed after refresh: $retryError');
            return [];
          }
        } else {
          debugPrint('❌ [Archive] Refresh returned null token, cannot retry.');
        }
      } else {
        debugPrint('❌ [Archive] Non-401 Error: $e');
      }
      return [];
    }
  }

  List<MyOrder> _handleSuccessfulResponse(dynamic res, int page) {
    List<MyOrder> items;
    if (res is (List<MyOrder>, int)) {
      items = res.$1;
      _totalPages = res.$2;
    } else if (res is List<MyOrder>) {
      items = res;
      if (items.length < perPage) _totalPages = page;
    } else {
      items = _extractItems(res).toList();
      if (items.length < perPage) _totalPages = page;
    }

    final active = items.firstWhereOrNull((o) => _isOngoing(o.status?.name, id: o.status?.id));
    if (active != null) {
      hasAcceptedOrder.value = true;
      latestActiveOrder.value = active;
    } else if (page == 1) {
      hasAcceptedOrder.value = false;
      latestActiveOrder.value = null;
    }

    return items;
  }

  Iterable<MyOrder> _extractItems(dynamic pageState) {
    if (pageState is List<MyOrder>) return pageState;

    try {
      final list = (pageState as dynamic).itemList as List<MyOrder>?;
      if (list != null) return list;
    } catch (_) {}

    try {
      final list = (pageState as dynamic).items as List<MyOrder>?;
      if (list != null) return list;
    } catch (_) {}

    return const <MyOrder>[];
  }

  Future<void> refreshData() async {
    // تحديث فوري للشارة والحالة النشطة لضمان التزامن مع الإشعارات
    await _prefetchBadgeOnly();
    
    // تحديث القائمة العامة في الخلفية
    _totalPages = null;
    pagingController.refresh();
  }

  Color getStatusColor(String? status, {int? id}) {
    if (id != null) {
      switch (id) {
        case 1:
          return Colors.orange;
        case 2:
        case 3:
        case 4:
        case 5:
          return Get.theme.primaryColor;
        case 6:
          return Colors.green;
        case 7:
        case 8:
          return Colors.red;
      }
    }

    switch (status) {
      case 'قيد الانتظار':
        return Colors.orange;
      case 'تم قبول الطلب':
      case 'مقبول':
        return Get.theme.primaryColor;
      case 'تم التوصيل':
        return Colors.green;
      case 'ملغية':
      case 'ملغية (قبل القبول)':
      case 'ملغية (بعد القبول)':
        return Colors.red;
      case 'في انتظار تفريغ الشحنة':
      case 'في انتظار تعبئة الشحنة':
      case 'تم تعبئة الشحنة':
      case 'في الطريق للمصدر':
      case 'وصل للمصدر':
      case 'قيد التوصيل':
        return Get.theme.primaryColor;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIconData(String? status, {int? id}) {
    if (id != null) {
      switch (id) {
        case 1:
          return Icons.radar_rounded;
        case 2:
          return Icons.check_circle_outline_rounded;
        case 3:
          return Icons.local_shipping_rounded;
        case 4:
          return Icons.person_pin_circle_rounded;
        case 5:
          return Icons.move_to_inbox_rounded;
        case 6:
          return Icons.verified_rounded;
        case 7:
        case 8:
          return Icons.cancel_outlined;
      }
    }

    switch (status) {
      case 'قيد الانتظار':
        return Icons.radar_rounded;
      case 'تم قبول الطلب':
      case 'مقبول':
        return Icons.check_circle_outline_rounded;
      case 'في انتظار تعبئة الشحنة':
        return Icons.hourglass_bottom_rounded;
      case 'تم تعبئة الشحنة':
        return Icons.inventory_2_rounded;
      case 'في الطريق':
      case 'في الطريق للمصدر':
        return Icons.local_shipping_rounded;
      case 'وصل السائق':
      case 'وصل للمصدر':
        return Icons.person_pin_circle_rounded;
      case 'في انتظار تفريغ الشحنة':
      case 'قيد التوصيل':
        return Icons.move_to_inbox_rounded;
      case 'تم التوصيل':
        return Icons.verified_rounded;
      case 'ملغية':
      case 'ملغية (قبل القبول)':
      case 'ملغية (بعد القبول)':
        return Icons.cancel_outlined;
      default:
        return Icons.local_shipping_rounded;
    }
  }

  String getStatusName(int id, String fallback) {
    switch (id) {
      case 1:
        return 'قيد الانتظار';
      case 2:
        return 'مقبول';
      case 3:
        return 'في الطريق للمصدر';
      case 4:
        return 'وصل للمصدر';
      case 5:
        return 'قيد التوصيل';
      case 6:
        return 'تم التوصيل';
      case 7:
        return 'ملغية (قبل القبول)';
      case 8:
        return 'ملغية (بعد القبول)';
      default:
        return fallback;
    }
  }

  String getStatusDescription(int id, String fallback) {
    switch (id) {
      case 1:
        return 'الطلب بانتظار قبول السائق';
      case 2:
        return 'السائق قبل الطلب';
      case 3:
        return 'السائق في طريقه إليك';
      case 4:
        return 'السائق وصل لنقطة التحميل';
      case 5:
        return 'جاري توصيل الشحنة';
      case 6:
        return 'اكتمل الطلب بنجاح';
      case 7:
        return 'إلغاء من قبل الزبون أو النظام';
      case 8:
        return 'إلغاء بعد بدء الرحلة';
      default:
        return fallback;
    }
  }

  String formatDate(String dateString) {
    try {
      final d = DateTime.parse(dateString);
      return "${d.year}/${_months[d.month - 1]}/${d.day}";
    } catch (_) {
      return dateString;
    }
  }

  static const List<String> _months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر'
  ];
}
