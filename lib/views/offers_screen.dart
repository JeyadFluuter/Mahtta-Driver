import 'package:piaggio_driver/constants/app_theme.dart';
// views/offers_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/logic/controller/offers_driver_controller.dart';
import 'package:piaggio_driver/model/offers_driver_model.dart';

class OffersScreen extends StatelessWidget {
  OffersScreen({super.key});

  final OffersDriverController ctrl = Get.put(OffersDriverController());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "العروض",
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
            if (ctrl.isLoading.value) {
              return Center(
                  child: CircularProgressIndicator(
                color: AppThemes.primaryNavy,
              ));
            }
            if (ctrl.offers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/x.png',
                      height: AppDimensions.screenHeight * 0.1,
                      width: AppDimensions.screenWidth * 0.5,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'لا توجد عروض حالياً',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: ctrl.offers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _OfferCard(offer: ctrl.offers[i]),
            );
          }),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final OffersDriverModel offer;
  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (offer.image.isNotEmpty)
            Stack(
              children: [
                Image.asset(
                  'assets/images/header.jpeg',
                  width: double.infinity,
                  height: AppDimensions.screenHeight * 0.20,
                  fit: BoxFit.cover,
                ),
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color.fromARGB(180, 0, 0, 0),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 12,
                  right: 16,
                  child: Text(
                    offer.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.body,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: const Color(0xFF374A6D),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.date_range, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'من ${offer.startsAt}',
                      style: theme.textTheme.bodySmall!
                          .copyWith(color: Colors.grey[700]),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'إلى',
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.av_timer, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      offer.endsAt,
                      style: theme.textTheme.bodySmall!
                          .copyWith(color: Colors.grey[700]),
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
}
