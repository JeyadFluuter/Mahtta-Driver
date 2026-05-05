// lib/views/pick_point_screen2.dart
import 'package:biadgo/constants/app_dimensions.dart';
import 'package:biadgo/logic/controller/map_controller2.dart';
import 'package:biadgo/logic/controller/my_locations_controller.dart';
import 'package:biadgo/models/new_location_model.dart';
import 'package:biadgo/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickPointScreen2 extends StatefulWidget {
  const PickPointScreen2({super.key, required this.isFirstPoint});
  final bool isFirstPoint;

  @override
  State<PickPointScreen2> createState() => _PickPointScreen2State();
}

class _PickPointScreen2State extends State<PickPointScreen2> {
  final MapController2 mapCtrl = Get.find<MapController2>();
  final MyLocationsController locCtrl = Get.find<MyLocationsController>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.isFirstPoint ? 'تحديد موقع الالتقاط' : 'تحديد موقع التسليم',
            style: const TextStyle(color: AppThemes.primaryNavy, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: AppThemes.primaryNavy),
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: .1),
        ),
        body: Obx(() {
          final src = locCtrl.dropdownLocations
              .where((l) => l.sourceAddress?.isNotEmpty ?? false)
              .toList();
          final dst = locCtrl.dropdownLocations
              .where((l) => l.destinationAddress?.isNotEmpty ?? false)
              .toList();

          final locationsList = widget.isFirstPoint ? src : dst;

          return ListView(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            children: [
              // Select from Map
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // Set picking mode and pop
                    mapCtrl.pickingMode.value = widget.isFirstPoint ? 1 : 2;
                    Get.back();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.map_outlined, color: AppThemes.primaryNavy, size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'تحديد الموقع على الخريطة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppThemes.primaryNavy,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppDimensions.paddingLarge),
              
              if (locationsList.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                  child: Text(
                    'المواقع المحفوظة',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: locationsList.length,
                    separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final loc = locationsList[index];
                      final label = widget.isFirstPoint ? loc.sourceAddress ?? '' : loc.destinationAddress ?? '';
                      
                      return InkWell(
                        onTap: () {
                          Get.back(); // إغلاق الشاشة فوراً لمنع الشاشة السوداء وتجنب التوجيه المزدوج

                          try {
                            // Update first location
                            final sLat = double.tryParse(loc.sourceLat ?? '');
                            final sLng = double.tryParse(loc.sourceLng ?? '');
                            if (sLat != null && sLng != null && sLat != 0) {
                              mapCtrl.updateFirstLocation(LatLng(sLat, sLng));
                            }

                            // Update second location
                            final dLat = double.tryParse(loc.destinationLat ?? '');
                            final dLng = double.tryParse(loc.destinationLng ?? '');
                            if (dLat != null && dLng != null && dLat != 0) {
                              mapCtrl.updateSecondLocation(LatLng(dLat, dLng));
                            }
                          } catch (e) {
                            debugPrint("Error updating locations: $e");
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Row(
                            children: [
                              Icon(
                                widget.isFirstPoint ? Icons.location_on : Icons.location_on,
                                color: widget.isFirstPoint ? AppThemes.pinAColor : AppThemes.pinBColor,
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: AppThemes.primaryNavy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}
