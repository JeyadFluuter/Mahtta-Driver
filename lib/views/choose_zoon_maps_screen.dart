import 'package:piaggio_driver/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:piaggio_driver/constants/app_dimensions.dart';
import 'package:piaggio_driver/logic/controller/set_Location_controller.dart';
import 'package:piaggio_driver/views/home_screen.dart';
import 'package:piaggio_driver/widgets/button.dart';
import 'package:piaggio_driver/constants/app_theme.dart';
class SelectZoneMap extends StatefulWidget {
  const SelectZoneMap({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SelectZoneMapState createState() => _SelectZoneMapState();
}

class _SelectZoneMapState extends State<SelectZoneMap> {
  GoogleMapController? _mapController;
  final box = GetStorage();
  LatLng _currentCenter = const LatLng(32.884232976730594, 13.18518451191319);
  final List<double> allowedRadiuses = [
    3000,
    4000,
    5000,
    6000,
    7000,
    8000,
    9000,
    10000
  ];
  double _radiusIndex = 0;
  double get currentRadius => allowedRadiuses[_radiusIndex.toInt()];
  final SetLocationController _locationController =
      Get.put(SetLocationController());

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
    _loadSavedZone();
  }

  void _loadSavedZone() {
    final lat = box.read('working_lat');
    final lng = box.read('working_lng');
    final radius = box.read('working_radius');
    debugPrint('📦 storage lat=$lat lng=$lng radius=$radius');
    if (lat is num && lng is num) {
      final latD = lat.toDouble();
      final lngD = lng.toDouble();
      final radD = (radius is num) ? radius.toDouble() : null;

      setState(() {
        _currentCenter = LatLng(latD, lngD);
        final idx =
            (radD == null) ? -1 : allowedRadiuses.indexWhere((r) => r == radD);

        _radiusIndex = idx >= 0 ? idx.toDouble() : 0;
      });
      if (_mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLng(_currentCenter));
      }
    }
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: isDarkMode ? AppThemes.primaryNavy : Colors.white,
          elevation: 0,
          title: Text(
            'اختر منطقتك',
            style: TextStyle(
                color: isDarkMode ? Colors.white : AppThemes.primaryNavy,
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.chevron_left_rounded,
                color: isDarkMode ? Colors.white : AppThemes.primaryNavy,
                size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              GoogleMap(
                onMapCreated: (controller) {
                  _mapController = controller;
                  if (isDarkMode) {
                    _mapController!.setMapStyle(_darkMapStyle);
                  }
                  _mapController!
                      .animateCamera(CameraUpdate.newLatLng(_currentCenter));
                },
                initialCameraPosition: CameraPosition(
                  target: _currentCenter,
                  zoom: 13,
                ),
                onTap: (point) {
                  setState(() => _currentCenter = point);
                },
                circles: {
                  Circle(
                    circleId: const CircleId('zone'),
                    center: _currentCenter,
                    radius: currentRadius,
                    fillColor: AppThemes.primaryOrange.withOpacity(0.1),
                    strokeColor: AppThemes.primaryOrange.withOpacity(0.5),
                    strokeWidth: 2,
                  ),
                },
                markers: {
                  Marker(
                    markerId: const MarkerId('center'),
                    position: _currentCenter,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueAzure),
                  ),
                },
                cameraTargetBounds: CameraTargetBounds(
                  LatLngBounds(
                    southwest: const LatLng(32.40, 12.70),
                    northeast: const LatLng(33.10, 14.60),
                  ),
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
              Positioned(
                top: 20,
                right: 16,
                child: Column(
                  children: [
                    _buildZoomButton(
                      icon: Icons.add,
                      onPressed: () =>
                          _mapController?.animateCamera(CameraUpdate.zoomIn()),
                    ),
                    const SizedBox(height: 12),
                    _buildZoomButton(
                      icon: Icons.remove,
                      onPressed: () =>
                          _mapController?.animateCamera(CameraUpdate.zoomOut()),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppThemes.primaryNavy.withOpacity(0.9)
                            : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.radar_rounded,
                              color: isDarkMode
                                  ? AppThemes.primaryOrange
                                  : AppThemes.primaryOrange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "نطاق العمل: ${currentRadius.toInt()} متر",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : AppThemes.primaryNavy,
                                  ),
                                ),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: AppThemes.primaryOrange,
                                    inactiveTrackColor: isDarkMode
                                        ? Colors.white24
                                        : Colors.grey[300],
                                    thumbColor: AppThemes.primaryOrange,
                                    overlayColor:
                                        AppThemes.primaryOrange.withOpacity(0.2),
                                    valueIndicatorColor: AppThemes.primaryNavy,
                                    valueIndicatorTextStyle: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                  child: Slider(
                                    value: _radiusIndex,
                                    min: 0,
                                    max: (allowedRadiuses.length - 1).toDouble(),
                                    divisions: allowedRadiuses.length - 1,
                                    onChanged: (value) {
                                      setState(() {
                                        _radiusIndex = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Button(
                      name: "تأكيد الموقع والنطاق",
                      isLoading: _isLoading,
                      onPressed: () async {
                        setState(() => _isLoading = true);
                        try {
                          final ok = await _locationController.sendLocation(
                            currentLat: _currentCenter.latitude,
                            currentLng: _currentCenter.longitude,
                            workingRadius: currentRadius,
                          );

                          if (ok == true) {
                            Get.back(result: {
                              'lat': _currentCenter.latitude,
                              'lng': _currentCenter.longitude,
                              'radius': currentRadius,
                            });
                            Get.offAll(() => HomeScreen());
                          }
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      size: Size(
                        AppDimensions.screenWidth * 0.8,
                        55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoomButton(
      {required IconData icon, required VoidCallback onPressed}) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDarkMode ? AppThemes.primaryNavy : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isDarkMode ? AppThemes.primaryOrange : AppThemes.primaryOrange,
          size: 20,
        ),
      ),
    );
  }
}

