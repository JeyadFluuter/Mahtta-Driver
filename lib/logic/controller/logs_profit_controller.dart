import 'package:get/get.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:piaggio_driver/model/logs_profit_models.dart';
import 'package:piaggio_driver/services/logs_profit_services.dart';

class LogsProfitController extends GetxController {
  final _service = LogsProfitServices();
  final records = <EarningRecord>[].obs;
  final isLoading = true.obs;
  final error = ''.obs;
  double get totalProfit => records.fold(0.0, (sum, r) => sum + r.earning);

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
        records.assignAll(resp.data.data);
      } else {
        error('حدث خطأ في جلب البيانات');
      }
    } finally {
      isLoading(false);
    }
  }

  String formatDate(DateTime dt) => DateFormat('yyyy-MM-dd – HH:mm').format(dt);
}
