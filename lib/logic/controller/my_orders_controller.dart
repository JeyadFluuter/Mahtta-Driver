import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:piaggio_driver/model/my_order_model.dart';
import 'package:piaggio_driver/services/my_orders_services.dart';

class MyOrderController extends GetxController {
  static const int _perPage = 15;
  final _service = MyOrderDataServices();
  final RxBool hasAcceptedOrder = false.obs;
  int? _totalPages;
  late final PagingController<int, MyOrder> pagingController =
      PagingController<int, MyOrder>(
    getNextPageKey: (state) {
      final next = (state.keys?.last ?? 0) + 1;
      if (_totalPages != null && next > _totalPages!) return null;
      return next;
    },
    fetchPage: (pageKey) async {
      final (items, totalPages) =
          await _service.fetchPage(page: pageKey, perPage: _perPage);
      _totalPages = totalPages;
      if (!hasAcceptedOrder.value &&
          items.any((o) => o.status?.name == 'في الطريق للمصدر')) {
        hasAcceptedOrder.value = true;
      }
      return items;
    },
  );

  @override
  void onInit() {
    super.onInit();
    pagingController.refresh();
  }

  @override
  void onClose() {
    pagingController.dispose();
    super.onClose();
  }

  Future<void> refreshData() async {
    hasAcceptedOrder.value = false;
    pagingController.refresh();
  }

  void searchOrders(String query) {
    if (query.isEmpty) {
      pagingController.refresh();
      return;
    }

    pagingController.value = pagingController.value
        .filterItems((order) => order.id.toString().contains(query))
        .copyWith(hasNextPage: false);
  }

  Color getStatusColor(String? status) {
    switch (status) {
      case 'قيد الانتظار':
        return Colors.orange;
      case 'مقبول':
        return Colors.blue;
      case 'في الطريق للمصدر':
        return Colors.blueAccent;
      case 'وصل للمصدر':
        return Colors.cyan;
      case 'قيد التوصيل':
        return Colors.indigo;
      case 'تم التوصيل':
        return Colors.green;
      case 'ملغية (قبل القبول)':
      case 'ملغية (بعد القبول)':
        return Colors.red;
      default:
        return Colors.grey;
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

  IconData getStatusIcon(String? status) {
    switch (status) {
      case 'قيد الانتظار':
        return Icons.timer_outlined;
      case 'مقبول':
        return Icons.check_circle_outline;
      case 'في الطريق للمصدر':
        return Icons.local_shipping_outlined;
      case 'وصل للمصدر':
        return Icons.location_on_outlined;
      case 'قيد التوصيل':
        return Icons.delivery_dining_outlined;
      case 'تم التوصيل':
        return Icons.celebration_outlined;
      case 'ملغية (قبل القبول)':
      case 'ملغية (بعد القبول)':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }
}
