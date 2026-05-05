import 'dart:async';
import 'package:dio/dio.dart';
import 'package:biadgo/constants/app_dimensions.dart';
import 'package:biadgo/logic/controller/confirm_order_controller.dart';
import 'package:biadgo/logic/controller/map_controller2.dart';
import 'package:biadgo/widgets/Orders/VehiclesAndLocationsScreen_cagro.dart';
import 'package:biadgo/widgets/Orders/insert_shepmentType.dart';
import 'package:biadgo/widgets/Orders/insert_location_point.dart';
import 'package:biadgo/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:biadgo/constants/app_theme.dart';
import 'package:get/get.dart';
import '../../logic/controller/shipment_types_controller.dart';

class LocationSearchResult {
  final String displayName;
  final LatLng point;
  LocationSearchResult(this.displayName, this.point);
}

class MakeOrder extends StatefulWidget {
  const MakeOrder({super.key});

  @override
  State<MakeOrder> createState() => _OpenstreetmapState();
}

class _OpenstreetmapState extends State<MakeOrder> {
  StreamSubscription<LocationData>? _locationSub;
  Worker? _firstWorker;
  Worker? _secondWorker;

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  final Location _location = Location();
  final MapController2 mapController2 = Get.put(MapController2());
  final ConfirmOrderController orderController =
      Get.put(ConfirmOrderController());

  bool _overlayVisible = true;
  bool locReady = false; // حصلنا أول Location
  final bool tilesReady = false; // أول رسم للتايل/الخريطة
  bool isLoading = true;
  LatLng? _currentLocation;
  List<LatLng> _routePoints = [];
  final double lastRotation = 0;
  bool followUser = true;
  double _sheetExtent = 0.45;

  LatLng _cameraCenter = const LatLng(32.8854, 13.1800);

  // Search Variables
  final TextEditingController _searchCtrl = TextEditingController();
  final RxString _searchText = ''.obs;
  final RxList<LocationSearchResult> _searchResults =
      <LocationSearchResult>[].obs;
  final RxBool _isSearching = false.obs;
  Timer? _debounce;

  void _onSearchChanged(String query) {
    _searchText.value = query;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _searchPlaces(query);
      } else {
        _searchResults.clear();
      }
    });
  }

  Future<void> _searchPlaces(String query) async {
    _isSearching.value = true;
    try {
      final uri =
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&countrycodes=ly';
      final dio = Dio();
      final res = await dio.get(uri,
          options: Options(headers: {'User-Agent': 'com.example.biadgo'}));

      if (res.statusCode == 200) {
        final List data = res.data;
        _searchResults.value = data
            .map((e) => LocationSearchResult(
                  e['display_name'] ?? '',
                  LatLng(double.parse(e['lat'].toString()),
                      double.parse(e['lon'].toString())),
                ))
            .toList();
      }
    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      _isSearching.value = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _firstWorker = ever(mapController2.firstLocation, (_) => _updateRoute());
    _secondWorker = ever(mapController2.secondLocation, (_) => _updateRoute());
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _overlayVisible) setState(() => _overlayVisible = false);
    });
  }

  Future<void> _initializeLocation() async {
    DateTime? lastUpdate; // آخر معالجة
    const updateInterval = Duration(milliseconds: 400);
    const double defaultZoom = 13.0;
    // 1) التحقق من الأذونات
    if (!await _checkRequestPremmissions()) return;

    // 2) جلب الموقع الحالي مرة واحدة
    try {
      final loc = await _location.getLocation();
      if (loc.latitude != null && loc.longitude != null && mounted) {
        _currentLocation = LatLng(loc.latitude!, loc.longitude!);
        locReady = true;
        isLoading = false;
        if (_mapController.isCompleted) {
          final controller = await _mapController.future;
          controller.animateCamera(
              CameraUpdate.newLatLngZoom(_currentLocation!, defaultZoom));
        }
        if (!mounted) setState(() {});
      }
    } catch (_) {
      // تجاهل الخطأ
    }

    // 3) الاشتراك في التغييرات اللحظية
    _locationSub = _location.onLocationChanged.listen((loc) {
      // سلامة البيانات
      if (!mounted || loc.latitude == null || loc.longitude == null) return;

      final now = DateTime.now();
      if (lastUpdate != null && now.difference(lastUpdate!) < updateInterval) {
        return;
      }
      lastUpdate = now;

      // تحديث الإحداثيات
      _currentLocation = LatLng(loc.latitude!, loc.longitude!);
    });
  }

  Future<bool> _checkRequestPremmissions() async {
    bool servicesEnabled = await _location.serviceEnabled();
    if (!servicesEnabled) {
      servicesEnabled = await _location.requestService();
      if (!servicesEnabled) return false;
    }

    PermissionStatus permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission == PermissionStatus.denied) {
        return false;
      }
    }

    if (permission == PermissionStatus.deniedForever) {
      return false;
    }
    return true;
  }

  // التحريك إلى الموقع الحالي
  Future<void> _userCurrentLocation() async {
    if (_currentLocation != null) {
      followUser = true; // رجّع التتبّع
      final controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentLocation!, zoom: 14, bearing: 0),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لم يتم العثور على الموقع الحالي")),
      );
    }
  }

  // يتم استدعاؤها عند كل تغيير للنقطتين
  Future<void> _updateRoute() async {
    final start = mapController2.firstLocation.value;
    final end = mapController2.secondLocation.value;

    if (start != null && end != null) {
      await _fetchRoute(start, end);
      followUser = false; // ⬅️ أوقف التتبّع
    } else {
      setState(() {
        _routePoints = [];
      });
      followUser = true; // رجّع التتبّع لما تختفي نقطة
    }
  }

  Future<void> _fetchRoute(LatLng pickup, LatLng dropoff) async {
    try {
      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '${pickup.longitude},${pickup.latitude};'
          '${dropoff.longitude},${dropoff.latitude}'
          '?overview=full&geometries=polyline';

      final dio = Dio();
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 'Ok' &&
            data['routes'] != null &&
            (data['routes'] as List).isNotEmpty) {
          final encodedPolyline = data['routes'][0]['geometry'] as String;
          final List<LatLng> routePoints = _decodePolyline(encodedPolyline);

          if (!mounted) return;

          setState(() {
            _routePoints = routePoints;
          });

          _moveCameraToBounds(); // اعمل fit على كامل المسار
        }
      }
    } catch (_) {
      // الخط المستقيم كخيار احتياطي
      if (!mounted) return;

      setState(() {
        _routePoints = [pickup, dropoff];
      });

      _moveCameraToBounds();
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0, lat = 0, lng = 0;

    while (index < encoded.length) {
      int shift = 0, result = 0, b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  // تحريك الكاميرا بحيث تظهر النقطتين والمسار
  Future<void> _moveCameraToBounds() async {
    if (_routePoints.isEmpty) return;

    double? minLat, maxLat, minLng, maxLng;
    for (final p in _routePoints) {
      if (minLat == null || p.latitude < minLat) minLat = p.latitude;
      if (maxLat == null || p.latitude > maxLat) maxLat = p.latitude;
      if (minLng == null || p.longitude < minLng) minLng = p.longitude;
      if (maxLng == null || p.longitude > maxLng) maxLng = p.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );

    if (_mapController.isCompleted) {
      final controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60.0));
    }
  }

  @override
  void dispose() {
    _locationSub?.cancel(); // أوقف الاستماع
    _firstWorker?.dispose(); // أوقف ever
    _secondWorker?.dispose();
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<DraggableScrollableNotification>(
        onNotification: (notification) {
          if (_sheetExtent != notification.extent) {
            setState(() {
              _sheetExtent = notification.extent;
            });
          }
          return true;
        },
        child: Stack(
          children: [
            // 1) الخريطة كخلفية كاملة
            Positioned.fill(
              child: Obx(() => GoogleMap(
                    mapType: MapType.normal,
                    // إضافة حشوة سفلية لكي يتمركز المسار أو الدبوس بشكل صحيح
                    padding: EdgeInsets.only(
                        bottom: mapController2.pickingMode.value > 0
                            ? 200.0
                            : AppDimensions.screenHeight * _sheetExtent),
                    initialCameraPosition: CameraPosition(
                      target:
                          _currentLocation ?? const LatLng(32.8854, 13.1800),
                      zoom: 15,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      if (!_mapController.isCompleted) {
                        _mapController.complete(controller);
                      }
                      if (mounted) {
                        setState(() => _overlayVisible = false);
                      }
                    },
                    onCameraMove: (position) {
                      _cameraCenter = position.target;
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    polylines: {
                      if (_routePoints.isNotEmpty)
                        Polyline(
                          polylineId: const PolylineId('route'),
                          points: _routePoints,
                          width: 5,
                          color: AppThemes.primaryOrange,
                        ),
                    },
                    markers: {
                      // Marker A
                      if (mapController2.firstLocation.value != null)
                        Marker(
                          markerId: const MarkerId('marker_a'),
                          position: mapController2.firstLocation.value!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              AppThemes.pinAHue),
                        ),
                      // Marker B
                      if (mapController2.secondLocation.value != null)
                        Marker(
                          markerId: const MarkerId('marker_b'),
                          position: mapController2.secondLocation.value!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              AppThemes.pinBHue),
                        ),
                    },
                  )),
            ),

            // 2) مؤشر التحميل
            if (_overlayVisible)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withValues(alpha: .85),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 38,
                        height: 38,
                        child: CircularProgressIndicator(
                            color: Get.theme.primaryColor),
                      ),
                      const SizedBox(height: 12),
                      const Text('جاري تجهيز الخريطة...',
                          style: TextStyle(
                              color: AppThemes.primaryNavy,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),

            // 3) زر تحديد موقع المستخدم
            Positioned.fill(
              child: Obx(() {
                if (mapController2.pickingMode.value > 0)
                  return const SizedBox.shrink();
                return Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: AppDimensions.screenHeight * _sheetExtent + 16,
                        right: AppDimensions.paddingMedium),
                    child: SizedBox(
                      width: 45,
                      height: 45,
                      child: FloatingActionButton(
                        backgroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onPressed: (_currentLocation != null)
                            ? _userCurrentLocation
                            : null,
                        child: Icon(
                          Icons.my_location,
                          color: Get.theme.primaryColor,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            // Center Pin for Picking Mode
            Positioned.fill(
              child: Obx(() {
                if (mapController2.pickingMode.value == 0)
                  return const SizedBox.shrink();
                final isFirst = mapController2.pickingMode.value == 1;
                return Container(
                  padding:
                      const EdgeInsets.only(bottom: 200.0), // match map padding
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        bottom: 25.0), // offset so the tip touches the center
                    child: Icon(
                      Icons.location_on,
                      size: 50,
                      color:
                          isFirst ? AppThemes.pinAColor : AppThemes.pinBColor,
                    ),
                  ),
                );
              }),
            ),

            // 4) النافذة المنزلقة أو زر التأكيد في وضع الاختيار
            Positioned.fill(
              child: Obx(() {
                if (mapController2.pickingMode.value > 0) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.all(AppDimensions.paddingMedium),
                      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            mapController2.pickingMode.value == 1
                                ? "حرك الخريطة لتحديد نقطة الالتقاط"
                                : "حرك الخريطة لتحديد نقطة التسليم",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppThemes.primaryNavy),
                          ),
                          const SizedBox(height: AppDimensions.paddingMedium),
                          Button(
                            name: "تأكيد الموقع",
                            onPressed: () {
                              if (mapController2.pickingMode.value == 1) {
                                mapController2
                                    .updateFirstLocation(_cameraCenter);
                              } else {
                                mapController2
                                    .updateSecondLocation(_cameraCenter);
                              }
                              // إغلاق لوحة المفاتيح ومسح البحث عند التأكيد
                              FocusScope.of(context).unfocus();
                              _searchCtrl.clear();
                              _searchText.value = '';
                              _searchResults.clear();

                              mapController2.pickingMode.value =
                                  0; // Exit picking mode
                            },
                            size: Size(AppDimensions.screenWidth * 0.8,
                                AppDimensions.buttonHeight),
                          ),
                          const SafeArea(child: SizedBox(height: 0)),
                        ],
                      ),
                    ),
                  );
                }

                return DraggableScrollableSheet(
                  initialChildSize: 0.45,
                  minChildSize: 0.15,
                  maxChildSize: 0.85,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, -5)),
                        ],
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingMedium,
                          vertical: AppDimensions.paddingSmall,
                        ),
                        child: Column(
                          children: [
                            // مقبض السحب
                            Center(
                              child: Container(
                                width: 40,
                                height: 5,
                                margin: const EdgeInsets.only(
                                    bottom: AppDimensions.paddingMedium),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            InsertLocationPoint(),
                            const SizedBox(height: AppDimensions.paddingMedium),
                            Obx(() {
                              final hasFirst =
                                  mapController2.firstLocation.value != null;
                              final hasSecond =
                                  mapController2.secondLocation.value != null;

                              if (hasFirst) {
                                final stCtrl =
                                    Get.find<ShipmentTypesController>();
                                final isAutoDispose = stCtrl
                                        .selectedShipmentType?.isAutoDispose ==
                                    1;
                                final hasTypeSelected =
                                    stCtrl.selectedShipmentTypeId.value > 0;

                                return Column(
                                  children: [
                                    const Divider(height: 32),
                                    InsertShepmenttype(),
                                    const SizedBox(
                                        height: AppDimensions.paddingLarge),
                                    if (hasTypeSelected) ...[
                                      VehiclesAndLocationsScreenCargo(),
                                      const SizedBox(
                                          height: AppDimensions.paddingLarge),
                                    ],
                                    if (hasSecond || isAutoDispose)
                                      Button(
                                        name: "تأكيد الطلب",
                                        isLoading:
                                            orderController.isLoading.value,
                                        onPressed: (orderController
                                                    .isLoading.value ||
                                                !hasTypeSelected)
                                            ? null
                                            : () async {
                                                if (await orderController
                                                    .validateAllFields(
                                                        context)) {
                                                  await orderController
                                                      .confirmOrder(context);
                                                }
                                              },
                                        size: Size(
                                          AppDimensions.screenWidth * 0.5,
                                          AppDimensions.buttonHeight,
                                        ),
                                      )
                                    else
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "بانتظار تحديد وجهة التوصيل...",
                                          style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 13),
                                        ),
                                      ),
                                  ],
                                );
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.all(
                                      AppDimensions.paddingLarge),
                                  child: Column(
                                    children: [
                                      Icon(Icons.pin_drop_outlined,
                                          size: 48,
                                          color: Colors.grey.shade300),
                                      const SizedBox(height: 16),
                                      Text(
                                        "الرجاء تحديد نقطة الالتقاط للمتابعة",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }),
                            const SafeArea(
                              top: false,
                              child:
                                  SizedBox(height: AppDimensions.paddingMedium),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // 5) شريط البحث العائم (يظهر فقط في وضع الاختيار)
            Positioned(
              top: MediaQuery.paddingOf(context).top +
                  AppDimensions.paddingMedium,
              left: AppDimensions.paddingMedium,
              right: AppDimensions.paddingMedium,
              child: Obx(() {
                if (mapController2.pickingMode.value == 0)
                  return const SizedBox.shrink();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 3)),
                        ],
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'ابحث عن منطقة، شارع، معلم...',
                          hintStyle: TextStyle(
                              color: Colors.grey.shade400, fontSize: 14),
                          prefixIcon: const Icon(Icons.search,
                              color: AppThemes.primaryNavy),
                          suffixIcon: _isSearching.value
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                )
                              : _searchText.value.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear,
                                          color: Colors.grey),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        _searchText.value = '';
                                        _searchResults.clear();
                                      },
                                    )
                                  : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    if (_searchResults.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        constraints: BoxConstraints(
                            maxHeight: AppDimensions.screenHeight * 0.35),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 3)),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _searchResults.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: Colors.grey.shade200),
                          itemBuilder: (context, index) {
                            final result = _searchResults[index];
                            return ListTile(
                              leading: const Icon(Icons.location_on,
                                  color: AppThemes.primaryNavy),
                              title: Text(result.displayName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 13, height: 1.4)),
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                _searchCtrl.clear();
                                _searchText.value = '';
                                _searchResults.clear();
                                final controller = await _mapController.future;
                                controller.animateCamera(
                                    CameraUpdate.newLatLngZoom(
                                        result.point, 16));
                              },
                            );
                          },
                        ),
                      ),
                    ]
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
