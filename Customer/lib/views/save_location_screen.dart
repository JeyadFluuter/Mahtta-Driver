/* lib/views/save_location_screen.dart */
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:biadgo/constants/app_theme.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_dimensions.dart';
import '../logic/controller/my_locations_controller.dart';
import '../logic/controller/delete_my_location_controller.dart';
import '../models/new_location_model.dart';
import 'new_location_screen.dart';

class SaveLocationScreen extends GetView<MyLocationsController> {
  const SaveLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deleteC = Get.put(DeleteMyLocationController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المواقع المحفوظة', style: TextStyle(color: AppThemes.primaryNavy, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: AppThemes.primaryNavy),
          ),
        ),
        body: Column(
          children: [
            _buildList(deleteC),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.to(() => const NewLocationScreen()),
          backgroundColor: Get.theme.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildList(DeleteMyLocationController deleteC) => Expanded(
        child: CustomRefreshIndicator(
          onRefresh: controller.refreshData,
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
              ],
            );
          },
          child: PagingListener<int, DataLocation>(
            controller: controller.pagingController,
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
                  itemBuilder: (_, __) => _buildShimmerLocationCard(),
                );
              }

              return PagedListView<int, DataLocation>(
                state: state,
                fetchNextPage: fetchNextPage,
                padding: const EdgeInsets.only(top: 4),
                builderDelegate: PagedChildBuilderDelegate<DataLocation>(
                  itemBuilder: (_, item, __) => Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingSmall,
                        horizontal: AppDimensions.paddingSmall),
                    child: _buildLocationCard(item, deleteC),
                  ),
                  noItemsFoundIndicatorBuilder: (_) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/not-found.png',
                          width: 180, height: 180),
                      const SizedBox(height: 16),
                      const Text('لا توجد مواقع محفوظة'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

  Widget _buildShimmerLocationCard() => Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingSmall * .9),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              children: [
                Container(
                  height: AppDimensions.screenHeight * .1,
                  width: AppDimensions.screenWidth * .1,
                  decoration: BoxDecoration(
                      color: Colors.grey[300]!,
                      borderRadius: BorderRadius.circular(15)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppDimensions.paddingLarge),
                      Container(
                          height: 10, width: 120, color: Colors.grey[300]!),
                      const SizedBox(height: 8),
                      Container(
                          height: 10, width: 120, color: Colors.grey[300]!),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildLocationCard(
      DataLocation item, DeleteMyLocationController deleteC) {
    final src = item.sourceAddress ?? '';
    final dst = item.destinationAddress ?? '';
    final hasSrc = src.isNotEmpty;
    final hasDst = dst.isNotEmpty;
    final onlyOne = (hasSrc && !hasDst) || (!hasSrc && hasDst);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Slidable(
        key: ValueKey(item.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          dismissible: DismissiblePane(onDismissed: () async {
            await deleteC.deleteLocation(item.id);
            controller.pagingController.refresh();
          }),
          children: [
            SlidableAction(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'حذف',
              borderRadius: BorderRadius.circular(15),
              onPressed: (_) async {
                await deleteC.deleteLocation(item.id);
                controller.pagingController.refresh();
              },
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Get.theme.cardColor,
            borderRadius:
                BorderRadius.circular(AppDimensions.screenHeight * .02),
          ),
          padding: const EdgeInsets.all(AppDimensions.paddingSmall * 1.5),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: onlyOne
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasSrc) _buildRow('مكان الحمولة', src, AppThemes.pinAColor),
                    if (hasSrc && hasDst)
                      Divider(color: Get.theme.primaryColor, indent: 15, endIndent: 15),
                    if (hasDst)
                      _buildRow('مكان تفريغ الحمولة', dst, Get.theme.primaryColor),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset('assets/images/map.png',
                    height: AppDimensions.screenHeight * .11,
                    width: AppDimensions.screenWidth * .4,
                    fit: BoxFit.cover),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value, Color iconColor) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.location_on, color: iconColor, size: 15),
            const SizedBox(width: 2),
            Text(title,
                style: const TextStyle(
                    color: AppThemes.primaryNavy,
                    fontSize: 14,
                    fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: AppDimensions.paddingSmall),
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.paddingMedium),
            child: Text('طرابلس - $value',
                style: const TextStyle(color: AppThemes.primaryNavy, fontSize: 13)),
          ),
        ],
      );
}
