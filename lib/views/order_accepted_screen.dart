import 'package:piaggio_driver/constants/app_theme.dart';
// lib/views/order_accepted_screen.dart

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:piaggio_driver/widgets/custom_google_map.dart';
import 'package:piaggio_driver/logic/controller/my_orders_controller.dart';
import 'package:piaggio_driver/services/order_request_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/logic/controller/location_controller.dart';
import 'package:piaggio_driver/logic/controller/order_request_controller.dart';
import 'package:piaggio_driver/logic/controller/order_tracking_controller.dart';
import 'package:piaggio_driver/logic/controller/update_status_order_controller.dart';
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/services/order_accepted_services.dart';
import 'package:piaggio_driver/views/home_screen.dart';
import 'package:piaggio_driver/widgets/button.dart';
import 'package:piaggio_driver/views/Customer_services_screen.dart';
import 'package:get/get.dart';

class OrderAcceptedScreen extends StatefulWidget {
  final int orderId;
  const OrderAcceptedScreen({super.key, required this.orderId});

  @override
  State<OrderAcceptedScreen> createState() => _OrderAcceptedScreenState();
}

class _OrderAcceptedScreenState extends State<OrderAcceptedScreen> {
  late final OrderTrackingController trackingCtrl;
  bool _didFit = false;
  final OrderController orderCtrl = Get.find<OrderController>();

  final UpdateStatusOrderController updateStatusOrderController =
      Get.put(UpdateStatusOrderController());

  final LocationController locationController = Get.find<LocationController>();

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();

    if (!Get.isRegistered<OrderTrackingController>()) {
      Get.put(OrderTrackingController(), permanent: true);
    }

    trackingCtrl = Get.find<OrderTrackingController>();

    _initOrder();

    // Handle cancellation
    ever(trackingCtrl.currentStatus, (status) {
      if (status?.id == 8 ||
          status?.name == 'ملغية (بعد القبول)' ||
          status?.name == 'cancelled') {
        Get.defaultDialog(
          title: "تنبيه",
          middleText: "تم إلغاء الطلب من قبل الزبون",
          confirm: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppThemes.primaryNavy),
            onPressed: () => Get.offAll(() => HomeScreen()),
            child: const Text("حسناً", style: TextStyle(color: Colors.white)),
          ),
        );
      }
    });

    // Expand sheet on status change or initial load (DISABLED as per user request)
    /*
    ever(trackingCtrl.currentStatus, (status) {
      if (status != null && _sheetController.isAttached) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _sheetController.animateTo(
            0.70, // maxChildSize
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
          );
        });
      }
    });
    */
  }

  Future<void> _initOrder() async {
    await OrderAcceptedServices().init(widget.orderId);
  }

  double _toDouble(String? s, {double fallback = 0.0}) {
    return double.tryParse(s?.trim() ?? '') ?? fallback;
  }

  Future<void> openPickupThenDropoff({
    required double driverLat,
    required double driverLng,
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
    required BuildContext context,
  }) async {
    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'origin': '$driverLat,$driverLng',
      'destination': '$dropLat,$dropLng',
      'waypoints': '$pickupLat,$pickupLng',
      'travelmode': 'driving',
    });

    debugPrint('Maps URL => $uri');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      log('❌ لم يتم العثور على تطبيق لفتح الخريطة');
    }
  }

  Future<void> _callPhone(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Obx(() {
            final orderData = trackingCtrl.orderResponse.value;
            if (orderData == null) {
              return Center(
                child: CircularProgressIndicator(color: AppThemes.primaryNavy),
              );
            }
            final order = orderData.order;
            final customer = orderData.customer;
            final driver = orderData.driver;
            final status = orderData.status;
            final fromLat = _toDouble(order.fromLat);
            final fromLng = _toDouble(order.fromLng);
            final toLat = _toDouble(order.toLat);
            final toLng = _toDouble(order.toLng);
            final driverLat = _toDouble(driver.currentLat);
            final driverLng = _toDouble(driver.currentLng);
            final LatLng fromPoint = LatLng(fromLat, fromLng);
            final LatLng toPoint = LatLng(toLat, toLng);


            return Stack(
              children: [
                ListenableBuilder(
                  listenable: _sheetController,
                  builder: (context, child) {
                    final double sheetHeight = _sheetController.isAttached 
                        ? _sheetController.size * MediaQuery.of(context).size.height 
                        : MediaQuery.of(context).size.height * 0.40;
                    return CustomGoogleMap(
                      pickup: fromPoint,
                      dropoff: toPoint,
                      bottomPadding: sheetHeight + 10, // Move logo and focus button above the sheet
                    );
                  },
                ),
                ListenableBuilder(
                  listenable: _sheetController,
                  builder: (context, child) {
                    final double sheetHeight = _sheetController.isAttached
                        ? _sheetController.size *
                            MediaQuery.of(context).size.height
                        : MediaQuery.of(context).size.height * 0.40;
                    return Positioned(
                      bottom: sheetHeight + 10, // Lowered closer to the sheet
                      right: 16,
                      child: FloatingActionButton(
                        backgroundColor: AppThemes.primaryOrange,
                        heroTag: 'googleMap',
                        mini: true,
                        onPressed: () async {
                          await openPickupThenDropoff(
                            driverLat: driverLat,
                            driverLng: driverLng,
                            pickupLat: fromLat,
                            pickupLng: fromLng,
                            dropLat: toLat,
                            dropLng: toLng,
                            context: context,
                          );
                        },
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              AssetImage("assets/images/google.png"),
                        ),
                      ),
                    );
                  },
                ),
                // ════════════════════════════
                // CLOSE BUTTON (TOP LEFT)
                // ════════════════════════════
                Positioned(
                  top: 16,
                  left: 16,
                  child: SafeArea(
                    child: GestureDetector(
                      onTap: () => Get.offAll(() => HomeScreen()),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: AppThemes.primaryNavy, size: 22),
                      ),
                    ),
                  ),
                ),
                DraggableScrollableSheet(
                  controller: _sheetController,
                  initialChildSize: 0.40,
                  minChildSize: 0.25, // Increased slightly to prevent overflow
                  maxChildSize: 0.70,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(32)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          // ════════════════════════════
                          // GRAB HANDLE
                          // ════════════════════════════
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),

                          // ════════════════════════════
                          // SCROLLABLE CONTENT
                          // ════════════════════════════
                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 1. Order ID & Type
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'الطلبية رقم',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '#${order.id}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppThemes.primaryNavy,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppThemes.primaryOrange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          order.shipmentType,
                                          style: const TextStyle(
                                            color: AppThemes.primaryOrange,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        icon: const Icon(Icons.support_agent,
                                            color: AppThemes.primaryNavy, size: 28),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          Get.to(() => const CustomerServicesScreen());
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // 2. Status Progress Card
                                  Obx(() {
                                    final currentOrder = trackingCtrl.orderResponse.value;
                                    if (currentOrder == null) return const SizedBox();
                                    final s = currentOrder.status;
                                    final color = Get.find<MyOrderController>().getStatusColor(s.name);
                                    final icon = Get.find<MyOrderController>().getStatusIcon(s.name);

                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: color.withOpacity(0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 52,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3)),
                                              ],
                                            ),
                                            child: Icon(icon, color: Colors.white, size: 26),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _getStatusText(s.id),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: AppThemes.primaryNavy,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                if (s.id <= 6)
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(10),
                                                          child: LinearProgressIndicator(
                                                            value: (s.id / 6).clamp(0.1, 1.0),
                                                            backgroundColor: Colors.grey.shade100,
                                                            valueColor: AlwaysStoppedAnimation<Color>(color),
                                                            minHeight: 5,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        "خطوة ${s.id}/6",
                                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 24),

                                  // 3. Customer Info (Moved up)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: AppThemes.primaryNavy.withOpacity(0.1),
                                          child: const Icon(Icons.person, color: AppThemes.primaryNavy),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${customer.firstName} ${customer.lastName}",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppThemes.primaryNavy,
                                                ),
                                              ),
                                              Text(
                                                customer.phone,
                                                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => _callPhone(customer.phone),
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: const BoxDecoration(
                                              color: AppThemes.primaryOrange,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.call, color: Colors.white, size: 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // 4. Route Information
                                  Text(
                                    'مسار الرحلة',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppThemes.primaryNavy.withOpacity(0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _addressTile(
                                    icon: Icons.radio_button_checked_rounded,
                                    iconColor: AppThemes.primaryOrange,
                                    title: 'نقطة الاستلام',
                                    subtitle: order.fromAddress,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Container(
                                      width: 2,
                                      height: 20,
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  _addressTile(
                                    icon: Icons.location_on_rounded,
                                    iconColor: AppThemes.pinBColor,
                                    title: 'نقطة التفريغ',
                                    subtitle: order.toAddress,
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // 5. Cargo Details (New Section)
                                  if (order.cargoDescription.isNotEmpty || order.cargoImage.isNotEmpty) ...[
                                    Text(
                                      'تفاصيل الشحنة',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppThemes.primaryNavy.withOpacity(0.5),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.grey.shade100),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (order.cargoDescription.isNotEmpty)
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Icon(Icons.description_outlined, size: 20, color: AppThemes.primaryNavy),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    order.cargoDescription,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: AppThemes.primaryNavy,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if (order.cargoDescription.isNotEmpty && order.cargoImage.isNotEmpty)
                                            const SizedBox(height: 16),
                                          if (order.cargoImage.isNotEmpty)
                                            GestureDetector(
                                              onTap: () {
                                                final imgUrl = order.cargoImage.startsWith('http') 
                                                  ? order.cargoImage 
                                                  : "$imageUrl${order.cargoImage}";
                                                Get.to(() => Scaffold(
                                                  backgroundColor: Colors.black,
                                                  appBar: AppBar(
                                                    backgroundColor: Colors.black,
                                                    iconTheme: const IconThemeData(color: Colors.white),
                                                    elevation: 0,
                                                  ),
                                                  body: Center(
                                                    child: InteractiveViewer(
                                                      child: Image.network(imgUrl),
                                                    ),
                                                  ),
                                                ));
                                              },
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(15),
                                                child: Image.network(
                                                  order.cargoImage.startsWith('http') 
                                                    ? order.cargoImage 
                                                    : "$imageUrl${order.cargoImage}",
                                                  width: double.infinity,
                                                  height: 180,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => Container(
                                                    height: 100,
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.shade50,
                                                      borderRadius: BorderRadius.circular(15),
                                                    ),
                                                    child: const Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                                                        SizedBox(height: 8),
                                                        Text("فشل تحميل الصورة", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                                      ],
                                                    ),
                                                  ),
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null) return child;
                                                    return Container(
                                                      height: 180,
                                                      width: double.infinity,
                                                      color: Colors.grey.shade50,
                                                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                  ],

                                  // 6. Financial Details Card (Moved down & Formatted)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: AppThemes.primaryNavy.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: AppThemes.primaryNavy.withOpacity(0.1)),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(child: _financialItem("إجمالي القيمة", "${order.priceEstimated} د.ل")),
                                        Container(height: 30, width: 1, color: AppThemes.primaryNavy.withOpacity(0.1)),
                                        Expanded(
                                          child: _financialItem(
                                            "صافي الربح",
                                            "${((double.tryParse(order.priceEstimated) ?? 0) * 0.8).toStringAsFixed(2)} د.ل",
                                            isNet: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),

                          // 6. Fixed Action Button
                          SafeArea(
                            top: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                              child: Obx(() {
                                final currentStatus = trackingCtrl.orderResponse.value?.status;
                                if (currentStatus == null) return const SizedBox();

                                return Button(
                                  name: updateStatusOrderController.isLoading.value &&
                                          updateStatusOrderController.optimisticName.value.isNotEmpty
                                      ? updateStatusOrderController.optimisticName.value
                                      : _getActionName(currentStatus.id),
                                  isLoading: updateStatusOrderController.isLoading.value,
                                  onPressed: () async {
                                    if (currentStatus.id == 6) {
                                      orderCtrl.clearCurrentOrder();
                                      final myOrders = Get.find<MyOrderController>();
                                      await myOrders.refreshData();
                                      await Get.find<PusherService>().ensureConnected(forceResubscribe: true);
                                      log('🛑 Status is 6 -> stop location sending');
                                      Get.find<LocationController>().stopLocationTimer();
                                      log('✅ تم إنهاء الطلب بنجاح');
                                      Future.delayed(const Duration(seconds: 2), () {
                                        Get.offAll(() => HomeScreen());
                                      });
                                    } else {
                                      updateStatusOrderController.updateStatus();
                                    }
                                  },
                                  size: Size(MediaQuery.of(context).size.width, 58),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          }),
      ),
    );
  }

  String _getActionName(int statusId) {
    switch (statusId) {
      case 2:
        return 'تأكيد التحرك للاستلام (A)';
      case 3:
        return 'تأكيد الوصول للاستلام (A)';
      case 4:
        return 'بدء التحرك للتسليم (B)';
      case 5:
        return 'تأكيد الوصول للتسليم (B)';
      case 6:
        return 'إنهاء الطلب وتأكيد التسليم';
      default:
        return 'تحديث الحالة';
    }
  }

  String _getStatusText(int statusId) {
    switch (statusId) {
      case 2:
        return 'الطلب مقبول';
      case 3:
        return 'في الطريق لنقطة الاستلام (A)';
      case 4:
        return 'وصلت لنقطة الاستلام (A)';
      case 5:
        return 'في الطريق لنقطة التسليم (B)';
      case 6:
        return 'وصلت لنقطة التسليم (B)';
      default:
        return 'جاري المتابعة';
    }
  }

  Widget _financialItem(String label, String value, {bool isNet = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isNet ? AppThemes.primaryOrange : AppThemes.primaryNavy,
          ),
        ),
      ],
    );
  }

  Widget _infoTile(String title, String value, IconData icon,
      {Color color = const Color.fromARGB(255, 51, 113, 236)}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black)),
            const SizedBox(width: 6),
            Icon(icon, size: 20, color: color),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
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
          style: TextStyle(
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
}
