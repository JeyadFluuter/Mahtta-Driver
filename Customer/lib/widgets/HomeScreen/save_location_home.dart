import 'package:biadgo/logic/controller/my_locations_controller.dart';
import 'package:biadgo/models/new_location_model.dart';
import 'package:biadgo/views/save_location_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:biadgo/constants/app_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants/app_dimensions.dart';

class SaveLocationHome extends StatelessWidget {
  SaveLocationHome({super.key});

  final MyLocationsController controller =
      Get.put(MyLocationsController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              right: AppDimensions.paddingMedium,
              left: AppDimensions.paddingSmall,
              bottom: AppDimensions.paddingSmall,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "المواقع المحفوظة",
                  style: TextStyle(
                    color: AppThemes.primaryNavy,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Get.to(() => const SaveLocationScreen());
                  },
                  child: Text(
                    "عرض المزيد",
                    style: TextStyle(
                      color: AppThemes.primaryNavy,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => controller.refreshData(),
              child: PagingListener<int, DataLocation>(
                controller: controller.pagingController,
                builder: (context, state, fetchNextPage) {
                  final loadingFirst = (state.pages?.isEmpty ?? true) &&
                      state.status == PagingStatus.loadingFirstPage;
                  if (loadingFirst) {
                    fetchNextPage();
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder: (_, __) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingSmall),
                        child: buildShimmerLocationCard(),
                      ),
                    );
                  }
                  return PagedListView<int, DataLocation>.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSmall,
                      vertical: AppDimensions.paddingSmall,
                    ),
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppDimensions.paddingMedium),
                    builderDelegate: PagedChildBuilderDelegate<DataLocation>(
                      itemBuilder: (_, item, __) => buildLocationField(item),
                      noItemsFoundIndicatorBuilder: (_) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/not-found.png',
                              width: 40, height: 40),
                          const SizedBox(height: 16),
                          const Text('لا توجد مواقع محفوظة'),
                        ],
                      ),
                    ),
                    state: state,
                    fetchNextPage: fetchNextPage,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildLocationField(DataLocation item) {
  final sourceAddress = item.sourceAddress ?? "";
  final destinationAddress = item.destinationAddress ?? "";
  bool onlyOne = (sourceAddress.isNotEmpty && destinationAddress.isEmpty) ||
      (sourceAddress.isEmpty && destinationAddress.isNotEmpty);

  return Container(
    width: AppDimensions.screenWidth * 0.8,
    decoration: BoxDecoration(
      color: Get.theme.cardColor,
      borderRadius: BorderRadius.circular(AppDimensions.screenHeight * 0.02),
    ),
    padding: const EdgeInsets.all(AppDimensions.paddingSmall),
    margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment:
                onlyOne ? MainAxisAlignment.center : MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (sourceAddress.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.location_on, color: AppThemes.pinAColor, size: 15),
                    const SizedBox(width: 2),
                    Text(
                      "مكان الحمولة",
                      style: TextStyle(
                        color: AppThemes.primaryNavy,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                Padding(
                  padding:
                      const EdgeInsets.only(right: AppDimensions.paddingMedium),
                  child: Text(
                    "طرابلس - $sourceAddress",
                    style: const TextStyle(color: AppThemes.primaryNavy, fontSize: 11),
                  ),
                ),
              ],
              if (sourceAddress.isNotEmpty && destinationAddress.isNotEmpty)
                Divider(
                  color: Get.theme.primaryColor,
                  indent: 15,
                  endIndent: 40,
                ),
              if (destinationAddress.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.location_on, color: AppThemes.primaryOrange, size: 15),
                    const SizedBox(width: 2),
                    Text(
                      "مكان تفريغ الحمولة",
                      style: TextStyle(
                        color: AppThemes.primaryNavy,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                Padding(
                  padding:
                      const EdgeInsets.only(right: AppDimensions.paddingMedium),
                  child: Text(
                    "طرابلس - $destinationAddress",
                    style: const TextStyle(color: AppThemes.primaryNavy, fontSize: 11),
                  ),
                ),
              ],
            ],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            "assets/images/map2.png",
            height: AppDimensions.screenHeight * 0.10,
            width: AppDimensions.screenWidth * 0.30,
            fit: BoxFit.cover,
          ),
        ),
      ],
    ),
  );
}

Widget buildShimmerLocationCard() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      width: AppDimensions.screenWidth * 0.6,
      height: AppDimensions.screenHeight * 0.2,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}
