import 'dart:convert';

import 'package:biadgo/constants/apiUrl.dart';

List<VehicleCategory> vehicleCategoryFromJson(String str) {
  final jsonData = json.decode(str);
  final dataList = jsonData["data"] as List;
  return dataList.map((item) => VehicleCategory.fromJson(item)).toList();
}

class VehicleCategory {
  final int id;
  final String? name;
  final String? description;
  final String? image;
  final List<Vehicle> vehicles;

  VehicleCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.vehicles,
  });

  factory VehicleCategory.fromJson(Map<String, dynamic> json) {
    final vehiclesJson = json["vehicles"] as List? ?? [];
    List<Vehicle> vehicleList =
        vehiclesJson.map((v) => Vehicle.fromJson(v)).toList();

    return VehicleCategory(
      id: json["id"] ?? 0,
      name: json["name"] ?? '',
      description: json["description"] ?? '',
      image: (json['image'] != null && json['image'].toString().isNotEmpty) ? "$ImageUrl${json['image']}" : null,
      vehicles: vehicleList,
    );
  }
}

class Vehicle {
  final int id;
  final String? name;
  final int? vehicleCategoryId;
  final String? description;
  final String? baseFare;
  final String? perKmRate;
  final String? image;

  Vehicle({
    required this.id,
    required this.name,
    required this.vehicleCategoryId,
    required this.description,
    required this.baseFare,
    required this.perKmRate,
    required this.image,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json["id"] ?? 0,
      name: json["name"] ?? '',
      vehicleCategoryId: json["vehicle_category_id"] ?? 0,
      description: json["description"] ?? '',
      baseFare: json["base_fare"] ?? '',
      perKmRate: json["per_km_rate"] ?? '',
      image: (json['image'] != null && json['image'].toString().isNotEmpty) ? "$ImageUrl${json['image']}" : null,
    );
  }
}
