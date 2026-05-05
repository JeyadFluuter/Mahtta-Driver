// ignore: file_names
import 'dart:convert';

class SetLocationModel {
  final double currentLat;
  final double currentLng;
  final double workingRadius;

  SetLocationModel({
    required this.currentLat,
    required this.currentLng,
    required this.workingRadius,
  });

  factory SetLocationModel.fromJson(String str) =>
      SetLocationModel.fromMap(json.decode(str));

  factory SetLocationModel.fromMap(Map<String, dynamic> json) =>
      SetLocationModel(
        currentLat: (json["current_lat"] as num?)?.toDouble() ?? 0.0,
        currentLng: (json["current_lng"] as num?)?.toDouble() ?? 0.0,
        workingRadius: (json["working_radius"] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toMap() => {
        "current_lat": currentLat,
        "current_lng": currentLng,
        "working_radius": workingRadius,
      };
}
