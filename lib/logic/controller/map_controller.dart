import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController extends GetxController {
  GoogleMapController? mapController;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void moveToLocation(LatLng position) {
    mapController?.animateCamera(CameraUpdate.newLatLng(position));
  }
}
