import 'package:piaggio_driver/constants/app_theme.dart';
// recordes_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/logic/controller/wallet_controller.dart';

class RecordesScreen extends StatelessWidget {
  RecordesScreen({super.key});
  final ctrl = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final logs = ctrl.recentLogs;
      if (logs.isEmpty) {
        return const Center(child: Text('لا يوجد سجلات بعد'));
      }
      return ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        itemCount: logs.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) {
          final log = logs[i];
          final bool isCredit =
              log.action == 'MANUAL_TOPUP' || log.action == 'CREDIT';
          final Color color = isCredit ? AppThemes.primaryOrange : AppThemes.light.colorScheme.error;
          final IconData icon = isCredit ? Icons.north_east : Icons.south_west;
          final String sign = isCredit ? '+' : '-';
          final double amount = double.tryParse(log.amount) ?? 0;
          return Container(
            height: AppDimensions.screenHeight * .10,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.description,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                        softWrap: true,
                      ),
                      const SizedBox(height: AppDimensions.paddingSmallX),
                      Text(
                        _formatDate(log.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Text(
                  "$sign${amount.toStringAsFixed(2)} د.ل",
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  String _formatDate(DateTime d) =>
      "${d.day} / ${d.month} / ${d.year} , ${d.hour}:${d.minute.toString().padLeft(2, '0')}";
}
