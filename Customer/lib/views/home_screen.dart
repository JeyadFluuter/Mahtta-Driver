import 'package:biadgo/constants/app_dimensions.dart';
import 'package:biadgo/logic/controller/home_controller.dart';
import 'package:biadgo/widgets/HomeScreen/VehiclesAndLocationsScreen_home.dart';
import 'package:biadgo/widgets/HomeScreen/header_home.dart';
import 'package:biadgo/widgets/HomeScreen/request_order.dart';
import 'package:biadgo/widgets/HomeScreen/save_location_home.dart';
import 'package:biadgo/views/save_location_screen.dart';
import 'package:biadgo/logic/controller/me_controller.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:biadgo/logic/controller/my_order_controller.dart';
import 'package:biadgo/logic/controller/confirm_order_controller.dart';
import 'package:biadgo/views/traceking_order_screen.dart';
import 'package:biadgo/widgets/Orders/SearchingDriverScreen.dart';
import 'package:biadgo/models/confirm_order_model.dart';
import 'package:biadgo/services/order_accepted_services.dart';
import 'package:biadgo/constants/app_theme.dart';
import 'package:biadgo/widgets/Orders/animation_status.dart';
import 'package:biadgo/models/order_data_model.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController ctrl = Get.put(HomeController());
  final MyOrderController orderCtrl = Get.find<MyOrderController>();
  final ConfirmOrderController confirmOrderCtrl = Get.find<ConfirmOrderController>();
  final MeController meCtrl = Get.put(MeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Obx(() {
          final first = meCtrl.firstname.value;
          final last = meCtrl.lastname.value;
          final name = (first.isEmpty && last.isEmpty) ? "زبوننا العزيز" : "$first $last";
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "مرحباً $name",
                style: const TextStyle(
                  color: AppThemes.primaryNavy,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "استمتع برحلاتك معنا",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          );
        }),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMediumX),
            child: InkWell(
              onTap: () {
                Get.to(() => const SaveLocationScreen());
              },
              child: Container(
                width: AppDimensions.paddingLarge * 1.6,
                height: AppDimensions.paddingLarge * 1.6,
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.share_location_outlined,
                    color: Get.theme.primaryColor, size: 22),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: null,
      body: CustomRefreshIndicator(
        onRefresh: ctrl.refreshAll,
        offsetToArmed: 80,
        builder: (context, child, indicator) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              if (!indicator.isIdle)
                Positioned(
                  top: 35.0 * indicator.value,
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Get.theme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: indicator.isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 20 + (5 * indicator.value).clamp(0, 5),
                            ),
                    ),
                  ),
                ),
              Transform.translate(
                offset: Offset(0, 100.0 * indicator.value),
                child: child,
              ),
              _buildActiveOrderStatus(),
              Obx(() => _buildConnectionBar() ?? const SizedBox.shrink()),
            ],
          );
        },
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return _buildSkeleton();
          }
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              HeaderHome(),
              const RequestOrder(),
              const SizedBox(height: AppDimensions.paddingSmall),
              VehiclesAndLocationsScreenHome(),
              const SizedBox(height: AppDimensions.paddingLarge),
              SizedBox(
                height: AppDimensions.screenHeight * 0.2,
                child: SaveLocationHome(),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Container(
            height: 180,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          Container(
            height: 100,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                  3,
                  (i) => Container(
                        width: AppDimensions.screenWidth * 0.28,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      )),
            ),
          ),
          const SizedBox(height: 30),
          Container(
            height: 150,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildConnectionBar() {
    if (!ctrl.isConnected.value) {
      return _bar(
        color: const Color(0xFFE11D48),
        icon: Icons.wifi_off_rounded,
        text: 'لا يوجد اتصال بالإنترنت',
      );
    }
    if (ctrl.showConnectedBar.value) {
      return _bar(
        color: const Color(0xFF10B981),
        icon: Icons.wifi_rounded,
        text: 'تم استعادة الاتصال بنجاح',
      );
    }
    return null;
  }

  Widget _bar({
    required Color color,
    required IconData icon,
    required String text,
  }) {
    return Positioned(
      top: 15,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.95),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildActiveOrderStatus() {
    return Obx(() {
      final orderFromList = orderCtrl.latestActiveOrder.value;
      final searchingOrder = confirmOrderCtrl.dataConfirmOrder.value;

      bool showBar = false;
      String status = 'قيد الانتظار';
      Color statusColor = Colors.orange;
      int? orderId;
      bool isSearching = false;

      // الأولوية دائماً للبيانات القادمة من السيرفر (قائمة الطلبات النشطة)
      if (orderFromList != null) {
        status = orderFromList.status?.name ?? 'قيد الانتظار';
        // إذا كان هناك طلب نشط فعلياً في السيرفر
        if (status != 'تم التوصيل' && !status.contains('ملغي') && !status.contains('ملغية')) {
          showBar = true;
          statusColor = orderCtrl.getStatusColor(status);
          orderId = orderFromList.id;
          isSearching = false;
          
          // إذا وجدنا الطلب نشطاً في السيرفر، نمسح جلسة البحث المحلية لتجنب التضارب
          if (searchingOrder != null && searchingOrder.orderId == orderId) {
             confirmOrderCtrl.clearSearchSession();
          }
        }
      } 
      
      // إذا لم يوجد طلب نشط في القائمة ولكن توجد جلسة بحث محلية
      if (!showBar && searchingOrder != null) {
        showBar = true;
        status = 'قيد الانتظار';
        statusColor = Colors.orange;
        orderId = searchingOrder.orderId;
        isSearching = true;
      }

      return Positioned(
        bottom: 25,
        left: 20,
        right: 20,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
                child: child,
              ),
            );
          },
          child: showBar
              ? _statusCard(
                  key: ValueKey('status-bar-$status-$isSearching-$orderId'),
                  status: status,
                  statusColor: statusColor,
                  orderId: orderId,
                  isSearching: isSearching,
                )
              : const SizedBox.shrink(key: ValueKey('status-bar-none')),
        ),
      );
    });
  }

  Widget _statusCard({
    Key? key,
    required String status,
    required Color statusColor,
    int? orderId,
    required bool isSearching,
  }) {
    return InkWell(
      key: key,
      onTap: () {
        if (isSearching || status == 'قيد الانتظار') {
          // جاري البحث: مجرد شكل ولا يذهب لأي واجهة
          return;
        } else if (orderId != null) {
          Get.to(() => TracekingOrderScreen(orderId: orderId));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: statusColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: (isSearching || status == 'قيد الانتظار')
                  ? Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: statusColor,
                        ),
                      ),
                    )
                  : Icon(
                      orderCtrl.getStatusIconData(status),
                      color: statusColor,
                      size: 22,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (isSearching || status == 'قيد الانتظار') ? "جاري البحث عن سائق..." : "طلب رقم #$orderId",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (!(isSearching || status == 'قيد الانتظار'))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppThemes.primaryNavy.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Text(
                      "عرض التفاصيل",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppThemes.primaryNavy,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: AppThemes.primaryNavy,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
