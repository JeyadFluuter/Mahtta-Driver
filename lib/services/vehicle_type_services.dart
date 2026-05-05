// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/model/vehicle_type_model.dart';

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
