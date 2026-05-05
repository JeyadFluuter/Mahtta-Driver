/* lib/logic/controller/hero_section_controller.dart */
import 'package:get/get.dart';
import '../../services/hero_section_services.dart';

class HeroSectionController extends GetxController {
  final heroImages = <String>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _getImages();
  }

  Future<void> _getImages() async {
    try {
      isLoading(true);
      errorMessage('');
      final response = await HeroSectionServices().heroSection();
      heroImages.assignAll(response.map((e) => e.image).toList());
    } catch (e) {
      errorMessage.value = 'خطأ في تحميل الصور: $e';
    } finally {
      isLoading(false);
    }
  }
}
