import 'package:biadgo/constants/apiUrl.dart';
import 'package:biadgo/models/vehicle_types_model.dart';
import 'package:http/http.dart' as http;

class VehicleCategoryService {
  Future<List<VehicleCategory>> fetchVehicleCategories() async {
    final response = await http.get(
      Uri.parse('$apiUrl/vehicle-types'),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final list = vehicleCategoryFromJson(response.body);
      return list;
    } else {
      throw Exception(
          "فشل في جلب تصنيفات المركبات. رمز الاستجابة: ${response.statusCode}");
    }
  }
}
