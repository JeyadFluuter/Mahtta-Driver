import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/logic/controller/order_accepted_controller.dart';
import 'package:piaggio_driver/logic/controller/rejection_order_controller.dart';
import 'package:piaggio_driver/model/order_request_model.dart';
import 'package:piaggio_driver/constants/api_Url.dart';

class OrderInfoCard extends StatefulWidget {
  final OrderData order;
  const OrderInfoCard({super.key, required this.order});

  @override
  State<OrderInfoCard> createState() => _OrderInfoCardState();
}

class _OrderInfoCardState extends State<OrderInfoCard> {
  final OrderAcceptedController acceptedCtrl =
      Get.find<OrderAcceptedController>();

  final RejectionOrderController rejectedCtrl =
      Get.find<RejectionOrderController>();

  @override
  void initState() {
    acceptedCtrl.setOrderId(widget.order.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
                            'وصلتك طلبية جديدة!',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppThemes.primaryOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '#${widget.order.id}',
                            style: TextStyle(
                              fontSize: 20,
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
                          color: AppThemes.primaryNavy.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.order.cargoDescription,
                          style: const TextStyle(
                            color: AppThemes.primaryNavy,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 2. Route Information
                  Text(
                    'مسار الرحلة (${widget.order.distanceKm} كم)',
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
                    subtitle: widget.order.fromAddress,
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
                    subtitle: widget.order.toAddress,
                  ),
                  const SizedBox(height: 24),

                  // 3. Financial Details
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppThemes.primaryNavy.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppThemes.primaryNavy.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _financialItem("إجمالي القيمة", "${widget.order.priceLyd} د.ل")),
                        Container(height: 30, width: 1, color: AppThemes.primaryNavy.withOpacity(0.1)),
                        Expanded(
                          child: _financialItem(
                            "صافي الربح",
                            "${(() {
                              double price = double.tryParse(widget.order.priceLyd) ?? 0.0;
                              double commission = double.tryParse(widget.order.commissionLyd) ?? 0.0;
                              if (commission == 0) {
                                return (price * 0.8).toStringAsFixed(2);
                              }
                              return (price - commission).toStringAsFixed(2);
                            })()} د.ل",
                            isNet: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
 
                  // 3.5. Cargo Details
                  if (widget.order.cargoDesc.isNotEmpty || widget.order.cargoImage.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.order.cargoDesc.isNotEmpty)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.description_outlined, size: 18, color: AppThemes.primaryNavy),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.order.cargoDesc,
                                    style: const TextStyle(fontSize: 13, color: AppThemes.primaryNavy),
                                  ),
                                ),
                              ],
                            ),
                          if (widget.order.cargoDesc.isNotEmpty && widget.order.cargoImage.isNotEmpty)
                            const SizedBox(height: 12),
                          if (widget.order.cargoImage.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                final imgUrl = widget.order.cargoImage.startsWith('http') 
                                  ? widget.order.cargoImage 
                                  : "$imageUrl${widget.order.cargoImage}";
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
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  widget.order.cargoImage.startsWith('http') 
                                    ? widget.order.cargoImage 
                                    : "$imageUrl${widget.order.cargoImage}",
                                  width: double.infinity,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
 
                  // 4. Action Buttons (With SafeArea)
                  SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        // Reject
                        GestureDetector(
                          onTap: () => rejectedCtrl.rejectCurrentOrder(),
                          child: Container(
                            height: 58,
                            width: 58,
                            decoration: BoxDecoration(
                              color: AppThemes.primaryNavy.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppThemes.primaryNavy.withOpacity(0.1)),
                            ),
                            child: const Icon(Icons.close_rounded, color: AppThemes.primaryNavy, size: 28),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Accept
                        Expanded(
                          child: GestureDetector(
                            onTap: () => acceptedCtrl.orderAccepted(),
                            child: Container(
                              height: 58,
                              decoration: BoxDecoration(
                                color: AppThemes.primaryNavy,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppThemes.primaryNavy.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'قبول الطلب',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _addressTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) =>
      Row(
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppThemes.primaryNavy,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      );
}
