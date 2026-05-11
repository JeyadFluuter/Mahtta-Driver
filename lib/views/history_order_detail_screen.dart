import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:piaggio_driver/logic/controller/my_orders_controller.dart';
import 'package:piaggio_driver/services/order_accepted_services.dart';
import 'package:piaggio_driver/model/order_data_model.dart';
import 'package:piaggio_driver/widgets/custom_google_map.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

class HistoryOrderDetailScreen extends StatefulWidget {
  final int orderId;
  const HistoryOrderDetailScreen({super.key, required this.orderId});

  @override
  State<HistoryOrderDetailScreen> createState() => _HistoryOrderDetailScreenState();
}

class _HistoryOrderDetailScreenState extends State<HistoryOrderDetailScreen> {
  bool isLoading = true;
  OrderResponse? orderResponse;
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() => isLoading = true);
    try {
      final response = await OrderAcceptedServices().getOrderDetails(widget.orderId);
      if (response != null) {
        setState(() {
          orderResponse = OrderResponse.fromJson(response);
          isLoading = false;
        });
      } else {
        Get.back();
        Get.snackbar("خطأ", "تعذر جلب تفاصيل الطلب", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('❌ _loadOrderDetails error: $e');
      Get.back();
      Get.snackbar("خطأ", "حدث خطأ غير متوقع", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  double _toDouble(dynamic s, {double fallback = 0.0}) {
    if (s == null) return fallback;
    return double.tryParse(s.toString().trim()) ?? fallback;
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
        body: isLoading || orderResponse == null
            ? _buildSkeleton()
            : Stack(
                children: [
                  _buildMap(),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: SafeArea(
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: const Icon(Icons.close_rounded, color: AppThemes.primaryNavy, size: 24),
                        ),
                      ),
                    ),
                  ),

                  DraggableScrollableSheet(
                    controller: _sheetController,
                    initialChildSize: 0.50,
                    minChildSize: 0.30,
                    maxChildSize: 0.85,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
                        ),
                        child: Column(
                          children: [
                            Center(
                              child: Container(
                                width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                controller: scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: _buildDetailsContent(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Stack(
        children: [
          Container(
            color: Colors.white,
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10)))),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 60, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                            const SizedBox(height: 8),
                            Container(width: 120, height: 22, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
                          ],
                        ),
                        Container(width: 90, height: 32, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(width: double.infinity, height: 85, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
                    const SizedBox(height: 24),
                    Container(width: double.infinity, height: 75, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
                    const SizedBox(height: 32),
                    Container(width: 80, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                        const SizedBox(width: 12),
                        Container(width: 180, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                        const SizedBox(width: 12),
                        Container(width: 150, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(width: double.infinity, height: 65, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    final order = orderResponse!.order;
    final fromLat = _toDouble(order.fromLat);
    final fromLng = _toDouble(order.fromLng);
    final toLat = _toDouble(order.toLat);
    final toLng = _toDouble(order.toLng);

    return ListenableBuilder(
      listenable: _sheetController,
      builder: (context, child) {
        final double sheetHeight = _sheetController.isAttached 
            ? _sheetController.size * MediaQuery.of(context).size.height 
            : MediaQuery.of(context).size.height * 0.50;
        
        return CustomGoogleMap(
          pickup: LatLng(fromLat, fromLng),
          dropoff: LatLng(toLat, toLng),
          bottomPadding: sheetHeight,
        );
      },
    );
  }

  Widget _buildDetailsContent() {
    final order = orderResponse!.order;
    final customer = orderResponse!.customer;
    final status = orderResponse!.status;
    final color = Get.find<MyOrderController>().getStatusColor(status.name);
    final icon = Get.find<MyOrderController>().getStatusIcon(status.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الطلبية رقم', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                Text('#${order.id}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppThemes.primaryNavy)),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(status.name, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('حالة الطلبية', style: TextStyle(fontSize: 12, color: color.withOpacity(0.7))),
                    Text(status.driverStatus.isNotEmpty ? status.driverStatus : status.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppThemes.primaryNavy)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(20)),
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
                    Text("${customer.firstName} ${customer.lastName}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppThemes.primaryNavy)),
                    Text(customer.phone, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _callPhone(customer.phone),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: AppThemes.primaryOrange, shape: BoxShape.circle),
                  child: const Icon(Icons.call, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Text('مسار الرحلة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppThemes.primaryNavy.withOpacity(0.5))),
        const SizedBox(height: 12),
        _addressTile(icon: Icons.radio_button_checked_rounded, iconColor: AppThemes.primaryOrange, title: 'نقطة الاستلام', subtitle: order.fromAddress),
        Padding(padding: const EdgeInsets.only(right: 12), child: Container(width: 2, height: 20, color: Colors.grey.shade200)),
        _addressTile(icon: Icons.location_on_rounded, iconColor: AppThemes.pinBColor, title: 'نقطة التفريغ', subtitle: order.toAddress),
        const SizedBox(height: 24),

        if (order.cargoDescription.isNotEmpty || order.cargoImage.isNotEmpty) ...[
          Text('تفاصيل الشحنة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppThemes.primaryNavy.withOpacity(0.5))),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order.cargoDescription.isNotEmpty)
                  Text(order.cargoDescription, style: const TextStyle(fontSize: 14, color: AppThemes.primaryNavy, height: 1.4)),
                if (order.cargoImage.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      order.cargoImage.startsWith('http') ? order.cargoImage : "$imageUrl${order.cargoImage}",
                      width: double.infinity, height: 180, fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

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
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _addressTile({required IconData icon, required Color iconColor, required String title, required String subtitle}) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              Text(subtitle, style: const TextStyle(fontSize: 14, color: AppThemes.primaryNavy, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _financialItem(String title, String value, {bool isNet = false}) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: AppThemes.primaryNavy.withOpacity(0.5))),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isNet ? AppThemes.primaryOrange : AppThemes.primaryNavy)),
      ],
    );
  }
}

