import 'package:get/get.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:biadgo/constants/app_dimensions.dart';
import 'package:biadgo/constants/app_theme.dart';
import 'package:biadgo/widgets/button.dart';

class SelectLocationScreen {
  final String displayName;
  final LatLng point;
  SelectLocationScreen(this.displayName, this.point);
}

class OpenstreetMapScreen extends StatefulWidget {
  final LatLng? initialLocation;
  const OpenstreetMapScreen({super.key, this.initialLocation});

  @override
  State<OpenstreetMapScreen> createState() => _OpenstreetMapScreenState();
}

class _OpenstreetMapScreenState extends State<OpenstreetMapScreen> {
  final Completer<GoogleMapController> _map = Completer<GoogleMapController>();
  final Location _loc = Location();
  final TextEditingController _searchCtrl = TextEditingController();
  LatLng? _currentLocation;
  bool followUser = true;

  LatLng? _selected;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLocation;
    _initCurrentLocation();
  }

  Future<void> _initCurrentLocation() async {
    if (!await _loc.serviceEnabled() && !await _loc.requestService()) {
      setState(() => loading = false);
      return;
    }
    var perm = await _loc.hasPermission();
    if (perm == PermissionStatus.denied) {
      perm = await _loc.requestPermission();
      if (perm != PermissionStatus.granted) {
        setState(() => loading = false);
        return;
      }
    }

    final l = await _loc.getLocation();
    if (!mounted) return;

    if (l.latitude != null && l.longitude != null) {
      final pos = LatLng(l.latitude!, l.longitude!);

      setState(() {
        _selected = pos;
        _currentLocation = pos;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          final GoogleMapController controller = await _map.future;
          controller.animateCamera(CameraUpdate.newLatLngZoom(pos, 15));
        }
      });
    }

    setState(() => loading = false);
  }

  Future<void> _userCurrentLocation() async {
    if (_currentLocation != null) {
      followUser = true;
      final GoogleMapController controller = await _map.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentLocation!, zoom: 14, bearing: 0),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لم يتم العثور على الموقع الحالي")),
      );
    }
  }

  Future<List<SelectLocationScreen>> _search(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=$query'
      '&format=json'
      '&limit=10'
      '&countrycodes=ly',
    );

    final res = await http.get(
      uri,
      headers: {
        'User-Agent': 'com.example.biadgo',
      },
    );
    if (res.statusCode != 200) return [];

    final List data = jsonDecode(res.body);
    return data
        .map((e) => SelectLocationScreen(
              e['display_name'],
              LatLng(double.parse(e['lat']), double.parse(e['lon'])),
            ))
        .toList();
  }

  void _showSearchSheet() async {
    final results = await _search(_searchCtrl.text);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (_) => results.isEmpty
          ? const Padding(padding: EdgeInsets.all(20), child: Text('لا نتائج'))
          : ListView.separated(
              itemCount: results.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final r = results[i];
                return ListTile(
                  title: Text(r.displayName, maxLines: 2),
                  onTap: () async {
                    Navigator.pop(context);
                    setState(() => _selected = r.point);
                    final GoogleMapController controller = await _map.future;
                    controller.animateCamera(CameraUpdate.newLatLngZoom(r.point, 15));
                  },
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('حدد الموقع على الخريطة'),
          backgroundColor: Get.theme.primaryColor,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'ابحث عن مكان …',
                        hintStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        isDense: true,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _showSearchSheet,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Get.theme.primaryColor, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Get.theme.primaryColor, width: 2),
                        ),
                      ),
                      onSubmitted: (_) => _showSearchSheet(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: _selected ?? const LatLng(32.8841, 13.1852),
                      zoom: 15,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      if (!_map.isCompleted) {
                        _map.complete(controller);
                      }
                    },
                    onTap: (latLng) => setState(() => _selected = latLng),
                    markers: {
                      if (_selected != null)
                        Marker(
                          markerId: const MarkerId('selected'),
                          position: _selected!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            AppThemes.pinAHue,
                          ),
                        ),
                    },
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    rotateGesturesEnabled: false,
                  ),
                  Positioned(
                    bottom: AppDimensions.paddingSmall,
                    right: AppDimensions.paddingSmall,
                    child: FloatingActionButton(
                      backgroundColor: Get.theme.primaryColor,
                      onPressed: _userCurrentLocation,
                      child: const Icon(Icons.my_location, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Button(
                  name: 'تأكيد الموقع',
                  onPressed: () {
                    if (_selected != null) Navigator.pop(context, _selected);
                  },
                  size: Size(
                    AppDimensions.screenWidth * 0.5,
                    AppDimensions.buttonHeight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
