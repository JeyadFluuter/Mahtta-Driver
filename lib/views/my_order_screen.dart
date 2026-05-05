import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:piaggio_driver/logic/controller/my_orders_controller.dart';
import 'package:piaggio_driver/model/my_order_model.dart';
import 'package:piaggio_driver/views/order_accepted_screen.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_theme.dart';

class MyOrderScreen extends StatelessWidget {
  MyOrderScreen({super.key});

  final MyOrderController c = Get.find<MyOrderController>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'إرشيف الطلبات',
            style: TextStyle(color: AppThemes.primaryNavy, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: AppThemes.primaryNavy, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: AppThemes.primaryNavy,
                  onRefresh: () async => c.refreshData(),
                  child: PagingListener<int, MyOrder>(
                    controller: c.pagingController,
                    builder: (context, state, fetchNextPage) {
                      final loadingFirst = (state.pages?.isEmpty ?? true) &&
                          state.status == PagingStatus.loadingFirstPage;

                      if (loadingFirst) {
                        fetchNextPage();
                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: 4,
                          itemBuilder: (_, __) => _buildShimmerCard(),
                        );
                      }
                      return PagedListView<int, MyOrder>(
                        state: state,
                        fetchNextPage: fetchNextPage,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingSmall,
                          horizontal: AppDimensions.paddingMedium,
                        ),
                        builderDelegate: PagedChildBuilderDelegate<MyOrder>(
                          itemBuilder: (_, order, __) => _buildOrderCard(order),
                          noItemsFoundIndicatorBuilder: (_) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/cancel-order.png',
                                  width: 180,
                                  height: 180,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'لا توجد طلبات حالية',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          noMoreItemsIndicatorBuilder: (_) =>
                              const SizedBox.shrink(),
                          firstPageErrorIndicatorBuilder: (_) => const Center(
                            child: Text('حدث خطأ، اسحب للتحديث'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(MyOrder order) {
    final number = order.id?.toString() ?? '';
    final status = order.status?.name ?? '';
    final date = order.createdAt ?? '----';
    final cost = (order.priceEstimated ?? 0).toStringAsFixed(2);
    final steps = [order.fromAddress ?? '', order.toAddress ?? ''];
    final statusColor = c.getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 237, 240, 248),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الطلبية رقم : $number',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppThemes.primaryNavy),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: AppThemes.primaryNavy),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              date,
              style: TextStyle(
                color: AppThemes.primaryNavy,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Row(
            children: [
              Icon(Icons.location_on, color: AppThemes.primaryOrange, size: 16),
              Icon(Icons.arrow_upward, color: AppThemes.primaryOrange, size: 16),
              Expanded(
                child: Text(
                  steps[0],
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(Icons.location_on, color: AppThemes.pinBColor, size: 16),
              Icon(Icons.arrow_downward, color: AppThemes.pinBColor, size: 16),
              Expanded(
                child: Text(
                  steps.length > 1 ? steps[1] : '',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Row(
            children: [
              const Icon(Icons.attach_money, color: Colors.green, size: 18),
              const SizedBox(width: 4),
              Text(
                'القيمة: $cost د.ل',
              ),
            ],
          ),
          const SizedBox(
            height: AppDimensions.paddingSmall,
          ),
          if (status != 'تم التوصيل' &&
              status != 'تم الإلغاء' &&
              status != 'قيد الانتظار')
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.map, size: 18),
                label: const Text(
                  'تتبع الطلب على الخريطة',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppThemes.primaryOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
                onPressed: () {
                  Get.to(() => OrderAcceptedScreen(orderId: order.id!));
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() => Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
}
