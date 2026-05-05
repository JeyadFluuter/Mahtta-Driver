import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';

class MeController extends GetxController {
  final GetStorage getStorage = GetStorage();
  var id = ''.obs;
  var status = ''.obs;
  var firstname = ''.obs;
  var lastname = ''.obs;
  var email = ''.obs;
  var isActive = ''.obs;
  var isVerified = ''.obs;
  var isApproved = false.obs;
  var phone = ''.obs;
  var driverImage = ''.obs;
  var hasVehicleData = false.obs;
  var currentLat = ''.obs;
  var currentLng = ''.obs;
  var averageRating = 0.0.obs;
  var ratingsCount = 0.obs;

  Future<bool> refreshMe() async {
    final token = getStorage.read<String>('token');
    if (token == null || token.isEmpty) return false;

    try {
      final res = await http.get(
        Uri.parse('$apiUrl/me'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final responseBody = json.decode(res.body);
        final userData = responseBody['data'] ?? {};
        final vehicleMap = userData['vehicles'] ?? {};

        id.value = (userData['id'] ?? '').toString();
        status.value = (userData['status'] ?? '').toString();
        firstname.value = userData['first_name'] ?? '';
        lastname.value = userData['last_name'] ?? '';
        email.value = userData['email'] ?? '';
        phone.value = (userData['phone'] ?? '').toString();
        final img = userData['driver_image'];
        driverImage.value = (img != null && img.toString().isNotEmpty)
            ? "$imageUrl$img"
            : '';
        isActive.value = (userData['is_active']?.toString() ?? '0');
        isVerified.value = (userData['is_verified']?.toString() ?? '0');

        // Rating fields
        averageRating.value = (userData['average_rating'] ?? userData['rating'] ?? 0).toDouble();
        ratingsCount.value = (userData['ratings_count'] ?? 0).toInt();

        final vehicles = userData['vehicles'];
        if (vehicles is List && vehicles.isNotEmpty) {
          final firstVehicle = vehicles[0];
          isApproved.value = (firstVehicle['is_approved'] == 1 ||
              firstVehicle['is_approved'] == true);
          hasVehicleData.value = true;
        } else if (vehicles is Map && vehicles.isNotEmpty) {
          isApproved.value = (vehicles['is_approved'] == 1 ||
              vehicles['is_approved'] == true);
          hasVehicleData.value = true;
        } else {
          isApproved.value = false;
          hasVehicleData.value = false;
        }

        currentLat.value = userData['current_lat']?.toString() ?? '';
        currentLng.value = userData['current_lng']?.toString() ?? '';
        return true;
      }

      if (res.statusCode == 401) {
        await logoutAndClear();
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logoutAndClear() async {
    await getStorage.remove('token');
    await getStorage.remove('id');
  }
}

