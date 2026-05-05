// ignore: file_names
import 'dart:convert';
import 'package:piaggio_driver/constants/api_Url.dart';

class AllShipmentTypesSignupModel {
  final int id;
  final String name;
  final String description;
  final String image;

  AllShipmentTypesSignupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AllShipmentTypesSignupModel && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory AllShipmentTypesSignupModel.fromMap(Map<String, dynamic> m) =>
      AllShipmentTypesSignupModel(
        id: m['id'] as int,
        name: m['name'] as String,
        description: m['description'] as String,
        image: m['image'] != null ? '$imageUrl${m['image']}' : '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'image': image,
      };
}

class ShipmentTypeSignupModelResponse {
  final List<AllShipmentTypesSignupModel> data;
  final int error;
  final String message;

  ShipmentTypeSignupModelResponse({
    required this.data,
    required this.error,
    required this.message,
  });

  factory ShipmentTypeSignupModelResponse.fromJson(String s) =>
      ShipmentTypeSignupModelResponse.fromMap(jsonDecode(s));

  factory ShipmentTypeSignupModelResponse.fromMap(Map<String, dynamic> m) =>
      ShipmentTypeSignupModelResponse(
        data: List<Map<String, dynamic>>.from(m['data'])
            .map(AllShipmentTypesSignupModel.fromMap)
            .toList(),
        error: m['error'] as int,
        message: m['message'] as String,
      );
}
