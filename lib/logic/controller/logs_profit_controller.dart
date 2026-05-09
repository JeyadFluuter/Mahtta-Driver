import 'package:get/get.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:piaggio_driver/model/logs_profit_models.dart';
import 'package:piaggio_driver/services/logs_profit_services.dart';

enum ProfitFilter { all, today, week, month }

class LogsProfitController extends GetxController {
  final _service = LogsProfitServices();
  
  final allRecords = <EarningRecord>[].obs;
  final records = <EarningRecord>[].obs;
  
  final currentFilter = ProfitFilter.all.obs;
  
  final isLoading = true.obs;
  final error = ''.obs;

  double get totalProfit => records.fold(0.0, (sum, r) => sum + r.earning);
  int get totalOrders => records.length;
  double get avgPerOrder => totalOrders == 0 ? 0.0 : totalProfit / totalOrders;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isLoading(true);
      error('');
      final resp = await _service.fetchWallet();

      if (resp != null) {
        allRecords.assignAll(resp.data.data);
        applyFilter(currentFilter.value);
      } else {
        error('حدث خطأ في جلب البيانات');
      }
    } finally {
      isLoading(false);
    }
  }

  void applyFilter(ProfitFilter filter) {
    currentFilter.value = filter;
    final now = DateTime.now();
    
    records.assignAll(allRecords.where((r) {
      final date = r.createdAt.toLocal();
      switch (filter) {
        case ProfitFilter.all:
          return true;
        case ProfitFilter.today:
          return date.year == now.year && date.month == now.month && date.day == now.day;
        case ProfitFilter.week:
          final diff = now.difference(date).inDays;
          return diff <= 7 && diff >= 0;
        case ProfitFilter.month:
          return date.year == now.year && date.month == now.month;
      }
    }).toList());
  }

  String formatDate(DateTime dt) => DateFormat('HH:mm - yyyy-MM-dd').format(dt.toLocal());
}
