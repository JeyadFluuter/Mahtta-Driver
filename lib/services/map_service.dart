import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapService {
  final Dio _dio = Dio();

  Future<List<LatLng>> fetchRoute(LatLng pickup, LatLng dropoff) async {
    try {
      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '${pickup.longitude},${pickup.latitude};'
          '${dropoff.longitude},${dropoff.latitude}'
          '?overview=full&geometries=polyline';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 'Ok' &&
            data['routes'] != null &&
            data['routes'].isNotEmpty) {
          final encodedPolyline = data['routes'][0]['geometry'];
          return _decodePolyline(encodedPolyline);
        }
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
    return [pickup, dropoff]; // Fallback to straight line
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }
}
