import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/services/map_service.dart';
import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:piaggio_driver/logic/controller/location_controller.dart';
import 'package:get_storage/get_storage.dart';
import 'package:piaggio_driver/routes/routes.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class CustomGoogleMap extends StatefulWidget {
  final LatLng? pickup;
  final LatLng? dropoff;
  final bool showRoute;
  final bool showEditZone;
  final double bottomPadding;

  const CustomGoogleMap({
    super.key,
    this.pickup,
    this.dropoff,
    this.showRoute = true,
    this.showEditZone = false,
    this.bottomPadding = 0,
  });

  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  GoogleMapController? _mapController;
  final Set<Polyline> _polylines = {};
  bool _isLoadingRoute = false;
  final MapService _mapService = MapService();
  final LocationController locCtrl = Get.find<LocationController>();
  BitmapDescriptor? _carIcon;

  // Dark style for Google Maps
  final String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]
''';

  @override
  void initState() {
    super.initState();
    _loadIcons();
    if (widget.showRoute && widget.pickup != null && widget.dropoff != null) {
      _fetchRoute();
    }
  }

  Future<void> _loadIcons() async {
    try {
      debugPrint("🚕 Loading car icon...");
      final ByteData data = await rootBundle.load('assets/images/car.png');
      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: 130, // Increased size
      );
      final ui.FrameInfo fi = await codec.getNextFrame();
      final ByteData? byteData = await fi.image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        _carIcon = BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
        debugPrint("✅ Car icon loaded successfully");
        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint("❌ Error loading car icon: $e");
    }
  }

  Set<Marker> _getMarkers() {
    final Set<Marker> markers = {};

    // Add driver location marker
    final lat = locCtrl.currentLoc?.latitude;
    final lng = locCtrl.currentLoc?.longitude;
    if (lat != null && lng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(lat, lng),
          icon: _carIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          rotation: locCtrl.currentLoc?.heading ?? 0,
          anchor: const Offset(0.5, 0.5),
          infoWindow: const InfoWindow(title: 'موقعك الحالي'),
        ),
      );
    }

    if (widget.pickup != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: widget.pickup!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'نقطة الالتقاط'),
        ),
      );
    }

    if (widget.dropoff != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: widget.dropoff!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'نقطة التسليم'),
        ),
      );
    }
    return markers;
  }

  Future<void> _fetchRoute() async {
    if (widget.pickup == null || widget.dropoff == null) return;
    
    setState(() => _isLoadingRoute = true);
    final routePoints = await _mapService.fetchRoute(widget.pickup!, widget.dropoff!);
    
    if (mounted) {
      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: routePoints,
            color: AppThemes.primaryOrange,
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            geodesic: true,
          ),
        );
        _isLoadingRoute = false;
      });
      _fitBounds();
    }
  }

  void _fitBounds() {
    if (_mapController != null) {
      LatLng southwest;
      LatLng northeast;

      if (widget.pickup != null && widget.dropoff != null) {
        southwest = LatLng(
          widget.pickup!.latitude < widget.dropoff!.latitude ? widget.pickup!.latitude : widget.dropoff!.latitude,
          widget.pickup!.longitude < widget.dropoff!.longitude ? widget.pickup!.longitude : widget.dropoff!.longitude,
        );
        northeast = LatLng(
          widget.pickup!.latitude > widget.dropoff!.latitude ? widget.pickup!.latitude : widget.dropoff!.latitude,
          widget.pickup!.longitude > widget.dropoff!.longitude ? widget.pickup!.longitude : widget.dropoff!.longitude,
        );
      } else {
        final lat = locCtrl.currentLoc?.latitude ?? 32.8872;
        final lng = locCtrl.currentLoc?.longitude ?? 13.1913;
        southwest = LatLng(lat - 0.01, lng - 0.01);
        northeast = LatLng(lat + 0.01, lng + 0.01);
      }

      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southwest, northeast: northeast),
        70,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    debugPrint("🗺️ Building Map with bottomPadding: ${widget.bottomPadding}");

    return GetBuilder<LocationController>(builder: (_) {
      final markers = _getMarkers();
      final lat = locCtrl.currentLoc?.latitude ?? 32.8872;
      final lng = locCtrl.currentLoc?.longitude ?? 13.1913;

      return Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (isDarkMode) {
                _mapController!.setMapStyle(_darkMapStyle);
              }
              _fitBounds();
            },
            initialCameraPosition: CameraPosition(
              target: widget.pickup ?? LatLng(lat, lng),
              zoom: 14.0,
            ),
            markers: markers,
            polylines: _polylines,
            mapType: MapType.normal,
            cameraTargetBounds: CameraTargetBounds(
              LatLngBounds(
                southwest: const LatLng(32.40, 12.70),
                northeast: const LatLng(33.10, 14.60),
              ),
            ),
            circles: const {},
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
          ),
          if (widget.showEditZone)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: 60 + widget.bottomPadding,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: AppThemes.primaryOrange,
                onPressed: () => Get.toNamed(AppRoute.selectZone),
                child: const Icon(Icons.edit_location_alt_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
        ],
      );
    });
  }
}
