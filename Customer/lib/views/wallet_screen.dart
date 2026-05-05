import 'package:get/get.dart';
import 'package:biadgo/constants/app_dimensions.dart';
import 'package:biadgo/views/balance_screen.dart';
import 'package:biadgo/views/recordes_screen.dart';
import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text("المحفظة"),
            backgroundColor: Get.theme.primaryColor,
            centerTitle: true,
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(0),
              child: SizedBox.shrink(),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: _balanceCard(),
              ),
              Material(
                color: Get.theme.primaryColor.withOpacity(.05),
                child: TabBar(
                  indicatorColor: Get.theme.primaryColor,
                  labelColor: Get.theme.primaryColor,
                  tabs: const [
                    Tab(
                      text: "الشحن",
                    ),
                    Tab(
                      text: "السجلات",
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    BalanceScreen(),
                    RecordesScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*──────────────────── بطاقة الرصيد ───────────────────*/
  Widget _balanceCard() => Container(
        height: AppDimensions.screenHeight * 0.25,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Get.theme.primaryColor.withOpacity(0.2),
              Get.theme.primaryColor.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.only(right: AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.paddingSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Mahtta",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Image.asset("assets/images/mahtta22.png", height: 80),
              ],
            ),
            const Spacer(),
            const Text(
              "الرصيد الحالي : ",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            const Text(
              "57.000 د.ل",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(left: AppDimensions.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "معاذ بن يوسف",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
          ],
        ),
      );
}
