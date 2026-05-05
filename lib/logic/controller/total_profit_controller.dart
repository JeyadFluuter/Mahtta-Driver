import 'package:get/get.dart';
import 'package:piaggio_driver/model/total_profit_model.dart';
import 'package:piaggio_driver/services/total_profit_services.dart';

class ProfitSummaryController extends GetxController {
  final _service = ProfitSummaryService();

  final summary = Rxn<ProfitSummary>();
  final isLoading = true.obs;
  final error = ''.obs;

  double get totalEarnings => summary.value?.totalEarnings ?? 0.0;
  int get totalOrders => summary.value?.totalOrders ?? 0;
  double get avgPerOrder => summary.value?.avgPerOrder ?? 0.0;

  @override
  void onInit() {
    super.onInit();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      isLoading(true);
      error('');
      final res = await _service.fetchSummary();
      if (res != null) {
        summary.value = res;
      } else {
        error('تعذّر جلب ملخّص الأرباح');
      }
    } finally {
      isLoading(false);
    }
  }
}
