// lib/widgets/rate_driver_sheet.dart
import 'package:biadgo/services/rating_driver_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../logic/controller/rating_driver_controller.dart';
import '../../constants/app_dimensions.dart';

class RateDriverSheet extends StatefulWidget {
  const RateDriverSheet({super.key, required this.orderId});
  final int orderId;

  @override
  State<RateDriverSheet> createState() => _RateDriverSheetState();
}

class _RateDriverSheetState extends State<RateDriverSheet>
    with WidgetsBindingObserver {
  final _dragCtrl = DraggableScrollableController();
  double _lastExtent = 0.52;
  bool _keyboardWasVisible = false;

  late final RateDriverController c = Get.put(
    RateDriverController(),
    tag: 'rate_${widget.orderId}',
    permanent: true,
  );

  @override
  void initState() {
    super.initState();
    Get.lazyPut<RatingService>(() => RatingService(), fenix: true);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dragCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final keyboardVisible =
        WidgetsBinding.instance.window.viewInsets.bottom > 0;

    if (keyboardVisible && !_keyboardWasVisible) {
      _lastExtent = _dragCtrl.size.clamp(0.2, 0.9);
      _dragCtrl.animateTo(
        1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }

    // انتقال من (مفتوح) → (مغلق)
    if (!keyboardVisible && _keyboardWasVisible) {
      // نفّذ بعد فاصل قصير لضمان استقرار الـ layout
      Future.delayed(const Duration(milliseconds: 60), () {
        if (!mounted) return;
        _dragCtrl.animateTo(
          _lastExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    }
    _keyboardWasVisible = keyboardVisible;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        controller: _dragCtrl,
        expand: false,
        minChildSize: 0.2,
        initialChildSize: 0.52,
        maxChildSize: 0.9,
        builder: (ctx, scrollCtrl) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SingleChildScrollView(
              controller: scrollCtrl,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 48,
                    backgroundImage: AssetImage('assets/images/profile2.png'),
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  Text(
                    'تقييم السائق',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Get.theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),
                  RatingBar.builder(
                    initialRating: 0,
                    minRating: 1,
                    itemCount: 5,
                    unratedColor: Colors.grey.shade300,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                    itemBuilder: (_, __) =>
                        Icon(Icons.star, size: 32, color: Get.theme.primaryColor),
                    onRatingUpdate: (val) => c.rating.value = val.toInt(),
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('سيئ', style: TextStyle(color: Colors.grey)),
                      Text('ممتاز', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  TextField(
                    controller: c.commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'اكتب تعليقك هنا (اختياري)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  SizedBox(
                    width: double.infinity,
                    child: Obx(
                      () => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Get.theme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: c.isLoading.value
                            ? null
                            : () => c.ratingDriver(
                                  orderId: widget.orderId,
                                  context: context,
                                ),
                        child: c.isLoading.value
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('تأكيد'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
