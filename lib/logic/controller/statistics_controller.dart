import 'package:get/get.dart';
import 'package:piaggio_driver/model/statistics_model.dart';
import 'package:piaggio_driver/services/statistics_services.dart';

class DriverStatsController extends GetxController {
  final _service = StatisticsServices();
  final stats = Rxn<StatisticsModel>();
  final RxList<double> weeklyRevenue = <double>[].obs;
  final isLoading = true.obs;
  final error = ''.obs;

  final period = '7d'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  Future<void> changePeriod(String newPeriod) async {
    if (period.value == newPeriod) return;
    period.value = newPeriod;
    await fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      isLoading(true);
      error('');
      final res = await _service.fetchStats(period: period.value);
      if (res != null) {
        stats.value = res;
      } else {
        error('تعذّر جلب الإحصاءات');
      }
    } finally {
      isLoading(false);
    }
  }

  double get totalRevenue => stats.value?.revenue ?? 0.0;
  int get totalOrders => stats.value?.orders ?? 0;
  double get averageOrder => stats.value?.avgOrderValue ?? 0.0;
  String get periodLabel => stats.value?.period ?? period.value;
  String get rangeLabel =>
      stats.value != null ? "${stats.value!.from} → ${stats.value!.to}" : '';
}
