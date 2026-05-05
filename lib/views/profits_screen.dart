import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/logic/controller/logs_profit_controller.dart';
import 'package:piaggio_driver/logic/controller/total_profit_controller.dart';

class ProfitsScreen extends StatelessWidget {
  ProfitsScreen({super.key});

  final logsController = Get.put(LogsProfitController());
  final summaryController = Get.put(ProfitSummaryController());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "الأرباح",
            style: TextStyle(color: AppThemes.primaryNavy, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: AppThemes.primaryNavy, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Obx(() {
            if (logsController.isLoading.value ||
                summaryController.isLoading.value) {
              return Center(
                  child: CircularProgressIndicator(
                color: AppThemes.primaryNavy,
              ));
            }
            if (logsController.error.isNotEmpty) {
              return Center(child: Text(logsController.error.value));
            }
            if (summaryController.error.isNotEmpty) {
              return Center(child: Text(summaryController.error.value));
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    children: [
                      Container(
                        height: AppDimensions.screenHeight * 0.12,
                        width: AppDimensions.screenWidth * 0.90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [AppThemes.primaryOrange, Color(0xFFE67E22)],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "اجمالي الرحلات",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(
                                      height: AppDimensions.paddingSmall),
                                  Text(
                                    summaryController.totalOrders.toString(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: AppDimensions.screenHeight * 0.10,
                              color: Colors.white.withValues(alpha: .5),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "اجمالي الارباح",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(
                                      height: AppDimensions.paddingSmall),
                                  Text(
                                    "${summaryController.totalEarnings.toStringAsFixed(0).replaceAllMapped(
                                          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                                          (m) => '${m[1]},',
                                        )} د.ل",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      Container(
                        height: AppDimensions.screenHeight * 0.07,
                        width: AppDimensions.screenWidth * 0.90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE6EAF8), Color(0xFFE9EDF6)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingMediumX),
                        child: Row(
                          children: [
                            Icon(Icons.trending_up,
                                color: AppThemes.primaryNavy, size: 20),
                            const SizedBox(width: AppDimensions.paddingSmall),
                            Text(
                              "متوسط الارباح",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppThemes.primaryNavy,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "${summaryController.avgPerOrder.toStringAsFixed(2)} د.ل",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppThemes.primaryNavy,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: Colors.grey.shade300,
                  height: 1,
                  indent: AppDimensions.screenWidth * 0.1,
                  endIndent: AppDimensions.screenWidth * 0.1,
                ),
                const SizedBox(height: AppDimensions.paddingMedium),

                //  سجلات الأرباح
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLarge,
                  ),
                  child: Row(
                    children: [
                      Text(
                        "سجلات الأرباح",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                Expanded(
                  child: Obx(() {
                    if (logsController.records.isEmpty) {
                      return _noProfitsWidget();
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingMedium,
                      ),
                      itemCount: logsController.records.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppDimensions.paddingSmall),
                      itemBuilder: (context, index) {
                        final rec = logsController.records[index];
                        final isPositive = rec.earning >= 0;
                        return Container(
                          height: AppDimensions.screenHeight * .10,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: .15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingMedium,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isPositive
                                    ? Icons.north_east
                                    : Icons.south_east,
                                size: 20,
                                color: isPositive ? Colors.green : AppThemes.light.colorScheme.error,
                              ),
                              const SizedBox(
                                  width: AppDimensions.paddingMedium),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "طلب #${rec.orderId}",
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                      softWrap: true,
                                    ),
                                    const SizedBox(
                                        height: AppDimensions.paddingSmallX),
                                    Text(
                                      logsController.formatDate(rec.createdAt),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                  width: AppDimensions.paddingMedium),
                              Text(
                                "${isPositive ? '+' : '-'} ${rec.earning.toStringAsFixed(2)} د.ل",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isPositive ? Colors.green : AppThemes.light.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

Widget _noProfitsWidget() => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/error-log.png',
            width: AppDimensions.screenWidth * 0.3,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          const Text(
            'لا توجد سجلات أرباح ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
