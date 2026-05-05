import 'package:get/get.dart';
import 'package:piaggio_driver/model/wallet_model.dart';
import 'package:piaggio_driver/services/wallet_srvices.dart';

class WalletController extends GetxController {
  final _service = WalletServices();
  final wallet = Rxn<Wallet>();
  final recentLogs = <WalletLog>[].obs;
  final isLoading = true.obs;
  final error = ''.obs;

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
        wallet.value = resp.data.wallet;
        recentLogs.assignAll(resp.data.recentLogs);
      } else {
        error('خطأ في جلب البيانات');
      }
    } finally {
      isLoading(false);
    }
  }
}
