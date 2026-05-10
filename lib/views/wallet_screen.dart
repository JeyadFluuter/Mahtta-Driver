import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/logic/controller/wallet_controller.dart';
import 'package:piaggio_driver/views/balance_screen.dart';
import 'package:piaggio_driver/views/recordes_screen.dart';

class WalletScreen extends StatelessWidget {
  WalletScreen({super.key});

  final ctrl = Get.put(WalletController());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              "المحفظة",
              style: TextStyle(color: AppThemes.primaryNavy, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left_rounded, color: AppThemes.primaryNavy, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(0),
              child: SizedBox.shrink(),
            ),
          ),
          body: SafeArea(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return _buildSkeleton();
              }
              if (ctrl.error.isNotEmpty) {
                return Center(child: Text(ctrl.error.value));
              }
              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingMediumX),
                      child: _balanceCard(ctrl),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      minHeight: 70,
                      maxHeight: 70,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingSmallX,
                            vertical: 8),
                        child: Material(
                          borderRadius: BorderRadius.circular(20),
                          color: AppThemes.primaryOrange.withValues(alpha: 0.1),
                          child: TabBar(
                            indicatorColor: AppThemes.primaryOrange,
                            labelColor: AppThemes.primaryOrange,
                            dividerColor: Colors.transparent,
                            unselectedLabelColor: Colors.grey,
                            tabs: const [Tab(text: "الشحن"), Tab(text: "السجلات")],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                body: TabBarView(
                  children: [
                    BalanceScreen(),
                    RecordesScreen(),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMediumX),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (_, __) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceCard(WalletController c) => Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppThemes.primaryOrange,
              const Color(0xFFE67E22),
              const Color(0xFFD35400),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppThemes.primaryOrange.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Subtle Background Pattern
            Positioned(
              top: -20,
              right: -20,
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 150,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "الرصيد المتاح",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(() => Text(
                                "${c.wallet.value?.balance.toString() ?? '0.00'} د.ل",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              )),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          "assets/images/Asset 3.png",
                          height: 30,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      // Simulated Chip
                      Container(
                        width: 45,
                        height: 35,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade200,
                              Colors.amber.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: CustomPaint(
                          painter: ChipPainter(),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => Text(
                            c.wallet.value?.username?.toUpperCase() ?? 'DRIVER NAME',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          )),
                      const Text(
                        "Mahttaa Pay",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.7, size.height), paint);
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
