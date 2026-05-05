import 'dart:convert';

class DriverLocationModel {
  final double currentLat;
  final double currentLng;
  final int? orderId;
  DriverLocationModel({
    required this.currentLat,
    required this.currentLng,
    this.orderId,
  });

  factory DriverLocationModel.fromJson(String str) =>
      DriverLocationModel.fromMap(json.decode(str));

  factory DriverLocationModel.fromMap(Map<String, dynamic> json) {
    dynamic data = json["data"] ?? json;
    
    // If it's a list, take the first element
    if (data is List && data.isNotEmpty) {
      data = data[0];
    }
    
    // If it's still not a map (e.g. empty list or something else), use an empty map
    final Map<String, dynamic> map = (data is Map) ? data.cast<String, dynamic>() : {};

    return DriverLocationModel(
      currentLat: double.tryParse(map["current_lat"].toString()) ?? 0.0,
      currentLng: double.tryParse(map["current_lng"].toString()) ?? 0.0,
      orderId: int.tryParse(map["order_id"].toString()),
    );
  }

  Map<String, dynamic> toMap() => {
        "current_lat": currentLat,
        "current_lng": currentLng,
        "order_id": orderId,
      };
}
