import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:biadgo/constants/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// ويدجت خريطة Google Maps مستقلة مع نظام التتبع والمسار
class TrackingMapWidget extends StatefulWidget {
  final LatLng pickupLatLng;
  final LatLng dropoffLatLng;
  final LatLng? driverLatLng;

  const TrackingMapWidget({
    super.key,
    required this.pickupLatLng,
    required this.dropoffLatLng,
    this.driverLatLng,
  });

  @override
  State<TrackingMapWidget> createState() => _TrackingMapWidgetState();
}

class _TrackingMapWidgetState extends State<TrackingMapWidget> {
  GoogleMapController? _mapController;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  bool _isLoadingRoute = false;

  BitmapDescriptor? _driverIcon;

  // تتبع القيم السابقة لتجنب إعادة الرسم غير الضرورية
  LatLng? _prevPickup;
  LatLng? _prevDropoff;
  LatLng? _prevDriver;

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    _initMarkers();
    _fetchRoute(widget.pickupLatLng, widget.dropoffLatLng);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> _loadCustomMarker() async {
    try {
      // تكبير حجم السيارة لتكون واضحة ومميزة (140 بكسل)
      final Uint8List markerIcon =
          await getBytesFromAsset('assets/images/car.png', 140);
      _driverIcon = BitmapDescriptor.fromBytes(markerIcon);
      if (mounted) _initMarkers();
    } catch (e) {
      print('⚠️ Error loading custom marker: $e');
    }
  }

  @override
  void didUpdateWidget(TrackingMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final pickupChanged = widget.pickupLatLng != _prevPickup;
    final dropoffChanged = widget.dropoffLatLng != _prevDropoff;
    final driverChanged = widget.driverLatLng != _prevDriver;

    if (pickupChanged || dropoffChanged) {
      _initMarkers();
      _fetchRoute(widget.pickupLatLng, widget.dropoffLatLng);
    } else if (driverChanged) {
      print('🗺️ Map: Driver position changed to ${widget.driverLatLng}. Updating marker and camera.');
      _updateDriverMarker();
      // تحريك الكاميرا لتشمل السائق مع المسار عند تحديث الموقع
      _fitBounds(widget.pickupLatLng, widget.dropoffLatLng,
          driver: widget.driverLatLng);
    }
  }

  // ─── تهيئة الـ markers ────────────────────────────────────────────────────

  void _initMarkers() {
    _prevPickup = widget.pickupLatLng;
    _prevDropoff = widget.dropoffLatLng;
    _prevDriver = widget.driverLatLng;

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('pickup'),
        position: widget.pickupLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(AppThemes.pinAHue),
        infoWindow: const InfoWindow(title: 'نقطة الالتقاط'),
      ),
      Marker(
        markerId: const MarkerId('dropoff'),
        position: widget.dropoffLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(AppThemes.pinBHue),
        infoWindow: const InfoWindow(title: 'نقطة التسليم'),
      ),
    };

    if (widget.driverLatLng != null) {
      markers.add(_buildDriverMarker(widget.driverLatLng!));
    }

    if (mounted) setState(() => _markers
      ..clear()
      ..addAll(markers));
  }

  void _updateDriverMarker() {
    _prevDriver = widget.driverLatLng;
    if (widget.driverLatLng == null) return;

    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'driver');
      _markers.add(_buildDriverMarker(widget.driverLatLng!));
    });
  }

  Marker _buildDriverMarker(LatLng pos) => Marker(
        markerId: const MarkerId('driver'),
        position: pos,
        icon: _driverIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'موقع السائق'),
        anchor: const Offset(0.5, 0.5),
      );

  // ─── fitBounds ────────────────────────────────────────────────────────────

  void _fitBounds(LatLng pickup, LatLng dropoff, {LatLng? driver}) {
    if (_mapController == null) return;

    double minLat = pickup.latitude < dropoff.latitude ? pickup.latitude : dropoff.latitude;
    double maxLat = pickup.latitude > dropoff.latitude ? pickup.latitude : dropoff.latitude;
    double minLng = pickup.longitude < dropoff.longitude ? pickup.longitude : dropoff.longitude;
    double maxLng = pickup.longitude > dropoff.longitude ? pickup.longitude : dropoff.longitude;

    if (driver != null) {
      if (driver.latitude < minLat) minLat = driver.latitude;
      if (driver.latitude > maxLat) maxLat = driver.latitude;
      if (driver.longitude < minLng) minLng = driver.longitude;
      if (driver.longitude > maxLng) maxLng = driver.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  // ─── جلب المسار ───────────────────────────────────────────────────────────

  Future<void> _fetchRoute(LatLng pickup, LatLng dropoff) async {
    if (!mounted) return;

    setState(() {
      _isLoadingRoute = true;
      _polylines.clear();
    });

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
            // تحديث markers لتشير إلى نقاط المسار الحقيقية
            if (routePoints.isNotEmpty) {
              _markers.removeWhere((m) =>
                  m.markerId.value == 'pickup' ||
                  m.markerId.value == 'dropoff');

              _markers.add(Marker(
                markerId: const MarkerId('pickup'),
                position: routePoints.first,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    AppThemes.pinAHue),
                infoWindow: const InfoWindow(title: 'نقطة الالتقاط'),
              ));

              _markers.add(Marker(
                markerId: const MarkerId('dropoff'),
                position: routePoints.last,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    AppThemes.pinBHue),
                infoWindow: const InfoWindow(title: 'نقطة التسليم'),
              ));
            }

            _polylines.add(Polyline(
              polylineId: const PolylineId('route'),
              points: routePoints,
              color: AppThemes.primaryOrange,
              width: 5,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              geodesic: true,
            ));
          });

          // ضبط الكاميرا بعد رسم المسار
          _fitBounds(
            routePoints.first,
            routePoints.last,
            driver: widget.driverLatLng,
          );
        }
      }
    } catch (_) {
      // الخط المستقيم كخيار احتياطي
      if (!mounted) return;

      setState(() {
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          points: [pickup, dropoff],
          color: AppThemes.primaryOrange.withOpacity(0.5),
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
        ));
      });

      _fitBounds(pickup, dropoff, driver: widget.driverLatLng);
    } finally {
      if (mounted) setState(() => _isLoadingRoute = false);
    }
  }

  // ─── فك ترميز polyline ────────────────────────────────────────────────────

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

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            _fitBounds(widget.pickupLatLng, widget.dropoffLatLng,
                driver: widget.driverLatLng);
          },
          initialCameraPosition: CameraPosition(
            target: widget.pickupLatLng,
            zoom: 14.0,
          ),
          markers: _markers,
          polylines: _polylines,
          mapType: MapType.normal,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
        ),

        // مؤشر تحميل المسار
        if (_isLoadingRoute)
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8)
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppThemes.primaryOrange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'جاري تحميل المسار...',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // أزرار الزوم
        Positioned(
          bottom: 20,
          right: 12,
          child: Column(
            children: [
              _zoomBtn(Icons.add, () {
                _mapController
                    ?.animateCamera(CameraUpdate.zoomIn());
              }),
              const SizedBox(height: 8),
              _zoomBtn(Icons.remove, () {
                _mapController
                    ?.animateCamera(CameraUpdate.zoomOut());
              }),
              const SizedBox(height: 8),
              _zoomBtn(Icons.my_location, () {
                _fitBounds(widget.pickupLatLng, widget.dropoffLatLng, driver: widget.driverLatLng);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _zoomBtn(IconData icon, VoidCallback onTap) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        elevation: 3,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: AppThemes.primaryNavy),
          ),
        ),
      );

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
