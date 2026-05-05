import 'package:get/get.dart';
import 'package:piaggio_driver/model/offers_driver_model.dart';
import 'package:piaggio_driver/services/offers_driver_services.dart';

class OffersDriverController extends GetxController {
  final _service = OffersDriverServices();
  final RxList<OffersDriverModel> offers = <OffersDriverModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOffers();
  }

  Future<void> loadOffers() async {
    try {
      isLoading.value = true;
      offers.assignAll(await _service.fetchOffers());
    } catch (e) {
      Get.snackbar('خطأ', 'تعذّر جلب العروض');
    } finally {
      isLoading.value = false;
    }
  }
}
