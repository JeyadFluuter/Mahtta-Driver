import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/logic/controller/statistics_controller.dart';

class StatisticsScreen extends StatelessWidget {
  StatisticsScreen({super.key});
  final statsController = Get.put(DriverStatsController());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "الإحصائيات",
            style: TextStyle(color: AppThemes.primaryNavy, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: AppThemes.primaryNavy, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Obx(() {
          if (statsController.isLoading.value) {
            return Center(
                child: CircularProgressIndicator(
              color: AppThemes.primaryNavy,
            ));
          }
          if (statsController.error.isNotEmpty) {
            return Center(child: Text(statsController.error.value));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.paddingSmall),
                _PeriodFilters(controller: statsController),
                const SizedBox(height: AppDimensions.paddingLarge * 1.2),
                Row(
                  children: [
                    _OrdersRingChart(total: statsController.totalOrders),
                    const SizedBox(width: AppDimensions.paddingMedium),
                    _OrdersInfo(total: statsController.totalOrders),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
                _TotalEarningsCard(total: statsController.totalRevenue),
                const SizedBox(height: AppDimensions.marginLarge),
                const _WeeklyBarChart(
                  data: [100, 200, 300, 400],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _PeriodFilters extends StatelessWidget {
  final DriverStatsController controller;
  const _PeriodFilters({required this.controller});
  static const _labels = {
    '7d': 'أسبوع',
    '30d': 'شهر',
    '90d': '3 أشهر',
    '365d': 'سنة',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "عرض النتائج خلال",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppThemes.primaryNavy,
            ),
          ),
          const SizedBox(
            height: AppDimensions.paddingMedium,
          ),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _labels.entries.map((e) {
                final active = e.key == controller.period.value;
                return GestureDetector(
                  onTap: () => controller.changePeriod(e.key),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: active ? AppThemes.primaryOrange : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: active ? AppThemes.primaryOrange : Colors.grey.shade300,
                        )),
                    child: Text(
                      e.value,
                      style: TextStyle(
                        color: active ? Colors.white : AppThemes.primaryNavy,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersRingChart extends StatelessWidget {
  final int total;
  const _OrdersRingChart({required this.total});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: PieChart(
        PieChartData(
          startDegreeOffset: -90,
          centerSpaceRadius: 46,
          sectionsSpace: 0,
          centerSpaceColor: Colors.white,
          sections: [
            PieChartSectionData(
              value: total.toDouble(),
              color: AppThemes.primaryOrange,
              radius: 20,
              title: '',
            ),
          ],
        ),
      ),
    ).withCenterText('$total', context);
  }
}

extension on Widget {
  Widget withCenterText(String text, BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          this,
          Text(
            text,
            style: TextStyle(
                fontSize: 25, fontWeight: FontWeight.bold, color: AppThemes.primaryNavy),
          ),
        ],
      );
}

class _OrdersInfo extends StatelessWidget {
  final int total;
  const _OrdersInfo({required this.total});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$total',
            style: TextStyle(
                fontSize: 25, fontWeight: FontWeight.w700, color: AppThemes.primaryNavy),
          ),
          Text('إجمالي الرحلات',
              style: TextStyle(fontSize: 14, color: AppThemes.primaryNavy)),
        ],
      ),
    );
  }
}

class _TotalEarningsCard extends StatelessWidget {
  final double total;
  const _TotalEarningsCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.screenHeight * 0.12,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppThemes.primaryOrange, Color(0xFFE67E22)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      padding:
          const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          const Icon(Icons.attach_money, color: Colors.white, size: 40),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('اجمالي الارباح',
                  style: TextStyle(fontSize: 14, color: Colors.white)),
              const SizedBox(height: AppDimensions.paddingSmall),
              Text(
                total.toStringAsFixed(2),
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  final List<double> data;
  const _WeeklyBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final bars = data
        .asMap()
        .entries
        .map(
          (e) => BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value,
                width: 20,
                color: AppThemes.primaryOrange,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
        )
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(16),
      height: AppDimensions.screenHeight * 0.35,
      child: BarChart(
        BarChartData(
          barGroups: bars,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: true, horizontalInterval: 300),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 40,
                interval: 250,
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, _) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                  child: Text(
                    ['الأول', 'الثاني', 'الثالث', 'الرابع'][val.toInt()],
                  ),
                ),
              ),
            ),
          ),
        ),
        swapAnimationDuration: const Duration(milliseconds: 800),
      ),
    );
  }
}
