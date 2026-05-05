import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shimmer/shimmer.dart';
import 'package:biadgo/logic/controller/my_order_controller.dart';
import 'package:biadgo/models/my_order_model.dart';
import 'package:biadgo/views/traceking_order_screen.dart';
import 'package:biadgo/constants/app_theme.dart';

class MyOrderScreen1 extends StatelessWidget {
  MyOrderScreen1({super.key});

  final MyOrderController c = Get.find<MyOrderController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إرشيف الطلبات', style: TextStyle(color: AppThemes.primaryNavy, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomRefreshIndicator(
              onRefresh: () async => c.refreshData(),
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
                                    size: 20 +
                                        (5 * indicator.value).clamp(0, 5),
                                  ),
                          ),
                        ),
                      ),
                    Transform.translate(
                      offset: Offset(0, 100.0 * indicator.value),
                      child: child,
                    ),
                  ],
                );
              },
              child: PagingListener<int, MyOrder>(
                key: const ValueKey('my-orders-paging'),
                controller: c.pagingController,
                builder: (context, state, fetchNextPage) {
                  final loadingFirst = (state.pages?.isEmpty ?? true) &&
                      state.status == PagingStatus.loadingFirstPage;

                  if (loadingFirst) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      fetchNextPage();
                    });
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: 4,
                      itemBuilder: (_, __) => _buildShimmerCard(),
                    );
                  }

                  return PagedListView<int, MyOrder>(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    padding: const EdgeInsets.only(top: 4),
                    builderDelegate: PagedChildBuilderDelegate<MyOrder>(
                      itemBuilder: (_, order, __) =>
                          _buildShipmentCard(order),
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
                              style: TextStyle(fontSize: 16, color: AppThemes.primaryNavy, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      noMoreItemsIndicatorBuilder: (_) =>
                          const SizedBox.shrink(),
                      firstPageErrorIndicatorBuilder: (_) => const Center(
                        child: Text('حدث خطأ، اسحب للتحديث', style: TextStyle(color: AppThemes.primaryNavy)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentCard(MyOrder order) {
    final shipmentNumber = order.id?.toString() ?? '';
    final status = order.status?.name ?? 'قيد المعالجة';
    final statusColor = c.getStatusColor(status);
    final fromAddress = order.fromAddress ?? 'غير محدد';
    final toAddress = order.toAddress ?? 'غير محدد';
    final date = c.formatDate(order.createdAt ?? '');
    final cost = (order.priceEstimated ?? 0).toStringAsFixed(2);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (status != 'تم التوصيل' &&
                  !status.contains('ملغي') &&
                  status != 'قيد الانتظار') {
                Get.to(() => TracekingOrderScreen(orderId: order.id!));
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Get.theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.tag,
                                size: 14, color: Get.theme.primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              shipmentNumber,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppThemes.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: statusColor.withOpacity(0.2)),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.radio_button_checked,
                              size: 20, color: Get.theme.primaryColor),
                          Container(
                            width: 2,
                            height: 30,
                            color: Colors.grey[200],
                          ),
                          Icon(Icons.location_on,
                              size: 20, color: Get.theme.primaryColor),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fromAddress,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppThemes.primaryNavy),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 25),
                            Text(
                              toAddress,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppThemes.primaryNavy),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            date,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            cost,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Get.theme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'د.ل',
                            style: TextStyle(
                              fontSize: 12,
                              color: Get.theme.primaryColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[200]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 80,
                        height: 25,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20))),
                    Container(
                        width: 60,
                        height: 20,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8))),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                    width: double.infinity, height: 15, color: Colors.white),
                const SizedBox(height: 10),
                Container(width: 200, height: 15, color: Colors.white),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 100, height: 15, color: Colors.white),
                    Container(width: 60, height: 25, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
