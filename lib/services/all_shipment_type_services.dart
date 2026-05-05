// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:piaggio_driver/constants/api_Url.dart';
import 'package:piaggio_driver/model/all_shipment_types_signUp_model.dart';

class AllShipmentTypeServices {
  Future<List<AllShipmentTypesSignupModel>> fetchAll() async {
    final res = await http.get(Uri.parse('$apiUrl/shipment-types'),
        headers: {'Content-Type': 'application/json'});
    return ShipmentTypeSignupModelResponse.fromJson(res.body).data;
  }
}
