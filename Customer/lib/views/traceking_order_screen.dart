import 'dart:async';
import 'dart:developer';
import 'package:biadgo/constants/app_theme.dart';
import 'package:biadgo/logic/controller/chat_controller.dart';
import 'package:biadgo/logic/controller/order_accepted_controller.dart';
import 'package:biadgo/logic/controller/rating_driver_controller.dart';
import 'package:biadgo/models/order_data_model.dart';
import 'package:biadgo/services/order_accepted_services.dart';
import 'package:biadgo/widgets/Orders/animation_status.dart';
import 'package:biadgo/widgets/Orders/tracking_map_widget.dart';
import 'package:biadgo/widgets/nav_bar.dart';
import 'package:biadgo/widgets/rating_driver_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class TracekingOrderScreen extends StatefulWidget {
  final int orderId;
  const TracekingOrderScreen({super.key, required this.orderId});

  @override
  State<TracekingOrderScreen> createState() => _TracekingOrderScreenState();
}

class _TracekingOrderScreenState extends State<TracekingOrderScreen> {
  final _trackingCtrl = Get.put<OrderTrackingController>(
    OrderTrackingController(),
    tag: 'tracking',
  );
  final ChatController chatController = Get.put(ChatController());

  Timer? _pollTimer;
  Worker? _responseWatcher;

  @override
  void initState() {
    super.initState();
    OrderAcceptedServices().markScreenOpened(widget.orderId);
    log('🚀 Starting tracking for order: ${widget.orderId}');
    _startTracking(widget.orderId);
  }

  Future<void> _callPhone(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    await launchUrl(uri);
  }

  Future<void> _startTracking(int id) async {
    _trackingCtrl.isLoading.value = true;
    try {
      final snap = await OrderAcceptedServices().getTracking(id);
      _trackingCtrl.setOrderResponse(snap);
    } finally {
      _trackingCtrl.isLoading.value = false;
    }

    await OrderAcceptedServices().init(id);

    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        final fresh = await OrderAcceptedServices().getTracking(id);
        _trackingCtrl.setOrderResponse(fresh);

        final status = fresh.order.status.name;
        if (status == 'تم التوصيل' ||
            status.contains('ملغي') ||
            status.contains('ملغية') ||
            status.contains('مرفوض')) {
          _pollTimer?.cancel();
        }
      } catch (_) {}
    });

    _responseWatcher = ever<OrderResponse?>(_trackingCtrl.orderResponse, (resp) {
      if (!mounted) return;
      setState(() {});

      // التحقق التلقائي من حالة "تم التوصيل" لإظهار التقييم
      if (resp != null && resp.order.status.id == 6) {
        log('🏁 Order delivered detected via watcher. Triggering rating flow.');
        // ننتظر قليلاً للتأكد من استقرار الواجهة قبل فتح التقييم
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) _onClose();
        });
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _responseWatcher?.dispose();
    OrderAcceptedServices().markScreenClosed(widget.orderId, dismissed: true);
    OrderAcceptedServices().dispose();
    if (Get.isRegistered<OrderTrackingController>(tag: 'tracking')) {
      Get.delete<OrderTrackingController>(tag: 'tracking');
    }
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        OrderAcceptedServices()
            .markScreenClosed(widget.orderId, dismissed: true);
        return true;
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Obx(() {
            final resp = _trackingCtrl.orderResponse.value;
            if (resp == null) {
              return Center(
                child: CircularProgressIndicator(
                  color: Get.theme.primaryColor,
                ),
              );
            }

            final from = _trackingCtrl.lastValidFrom;
            final to = _trackingCtrl.lastValidTo;
            final driverPos =
                _trackingCtrl.driverLivePos.value ?? _trackingCtrl.lastValidDriver;

            if (from == null || to == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Stack(
              children: [
                // ── الخريطة تملأ الشاشة كاملاً ──
                Positioned.fill(
                  child: TrackingMapWidget(
                    pickupLatLng: LatLng(from.latitude, from.longitude),
                    dropoffLatLng: LatLng(to.latitude, to.longitude),
                    driverLatLng: driverPos != null
                        ? LatLng(driverPos.latitude, driverPos.longitude)
                        : null,
                  ),
                ),

                // ── زر الإغلاق ──
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  right: 16,
                  child: _buildCloseButton(),
                ),

                // ── Bottom Sheet لتفاصيل الطلب ──
                _buildInfoSheet(resp.order, resp.order.driver, resp.order.status),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ─── زر إغلاق الشاشة ─────────────────────────────────────────────────────

  Widget _buildCloseButton() => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        elevation: 4,
        child: InkWell(
          onTap: _onClose,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: const Icon(Icons.close, color: AppThemes.primaryNavy, size: 22),
          ),
        ),
      );

  // ─── Bottom Sheet للتفاصيل ────────────────────────────────────────────────

  Widget _buildInfoSheet(Order order, Driver driver, Status status) {
    return DraggableScrollableSheet(
      initialChildSize: 0.38,
      minChildSize: 0.18,
      maxChildSize: 0.55,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 14)],
        ),
        child: SingleChildScrollView(
          controller: scrollCtrl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── مقبض السحب ──
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // ── رقم الطلب ──
                Row(
                  children: [
                    Text(
                      'الطلبية رقم : ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppThemes.primaryNavy,
                      ),
                    ),
                    Text(
                      '#${order.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppThemes.primaryNavy,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── بطاقة حالة الطلب المتحركة ──
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    'حالة الطلب',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.primaryNavy,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                StatusCardAnimated(status: status),

                // ── معلومات السائق ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${driver.firstName} ${driver.lastName}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppThemes.primaryNavy,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.star,
                                color: Colors.orange, size: 15),
                            const SizedBox(width: 2),
                            Text(
                              driver.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.orange),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'نوع الشاحنة : ${order.vehicleType.name}',
                          style: const TextStyle(
                              fontSize: 13, color: AppThemes.primaryNavy),
                        ),
                      ],
                    ),
                    IconButton(
                      icon:
                          Icon(Icons.call, color: Get.theme.primaryColor, size: 26),
                      onPressed: () {
                        _callPhone(driver.phone);
                        log(driver.phone);
                      },
                    ),
                  ],
                ),

                Divider(
                  color: Get.theme.primaryColor.withOpacity(0.3),
                  thickness: 1,
                  endIndent: 20,
                  indent: 20,
                ),

                // ── عناوين الاستلام والتسليم ──
                _addressTile(
                  icon: Icons.location_on,
                  iconColor: AppThemes.pinAColor,
                  title: 'عنوان استلام البضاعة',
                  subtitle: order.fromAddress,
                ),
                _addressTile(
                  icon: Icons.location_on,
                  iconColor: Get.theme.primaryColor,
                  title: 'عنوان تفريغ البضاعة',
                  subtitle: order.toAddress,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _addressTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: iconColor, size: 26),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppThemes.primaryNavy,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13),
        ),
      );

  // ─── إغلاق الشاشة ────────────────────────────────────────────────────────

  bool _ratingSheetOpen = false;

  void _onClose() {
    final status = _trackingCtrl.orderResponse.value?.order.status;
    OrderAcceptedServices().markScreenClosed(widget.orderId, dismissed: true);

    if (status?.id != 6 && status?.name != 'تم التوصيل') {
      Get.offAll(() => NavBar());
      return;
    }

    if (_ratingSheetOpen || Get.isBottomSheetOpen == true) return;
    _ratingSheetOpen = true;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RateDriverSheet(orderId: widget.orderId),
    ).whenComplete(() {
      _ratingSheetOpen = false;
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.delete<RateDriverController>(
          tag: 'rate_${widget.orderId}',
          force: true,
        );
        Get.offAll(() => NavBar());
      });
    });
  }
}
