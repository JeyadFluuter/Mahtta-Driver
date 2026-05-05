import 'package:biadgo/constants/apiUrl.dart';
import 'package:biadgo/models/update_profile_model.dart';
import 'package:flutter/rendering.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class UpdateProfileServices {
  Future<UpdateProfile?> updateresponse({
    required String? firstName,
    required String? lastName,
    required String? city,
    required String? email,
    String? image,
  }) async {
    try {
      final GetStorage getStorage = GetStorage();
      final token = getStorage.read('token') as String?;
      final Uri url = Uri.parse('$apiUrl/update-profile');
      final response = await http.post(
        url,
        body: {
          '_method': 'PUT',
          'first_name': firstName,
          'last_name': lastName,
          'city': city,
          'email': email,
          if (image != null && image.isNotEmpty) 'image': image,
        },
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        final updateProfile = UpdateProfile.fromJson(responseBody);

        return updateProfile;
      } else {
        debugPrint('خطاء في الاستجابة: ${response.statusCode}');
        debugPrint('نص الاستجابة: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('خطأ أثناء الإتصال بالسيرفر: $e');
      return null;
    }
  }
}
