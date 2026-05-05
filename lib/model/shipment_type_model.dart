import 'dart:convert';
import 'package:piaggio_driver/constants/api_Url.dart';

class ShipmentTypeModel {
  final int id;
  final String name;
  final String description;
  final String? image;
  final bool isSelected;

  ShipmentTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.isSelected,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShipmentTypeModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory ShipmentTypeModel.fromMap(Map<String, dynamic> map) =>
      ShipmentTypeModel(
        id: map['id'] as int,
        name: map['name'] as String,
        description: map['description'] as String,
        image: map['image'] != null ? "$imageUrl${map['image']}" : '',
        isSelected: map['is_selected'] as bool,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'image': image,
        'is_selected': isSelected,
      };
}

class ShipmentTypeModelResponse {
  final List<ShipmentTypeModel> data;
  final int error;
  final String message;

  ShipmentTypeModelResponse({
    required this.data,
    required this.error,
    required this.message,
  });

  factory ShipmentTypeModelResponse.fromJson(String source) =>
      ShipmentTypeModelResponse.fromMap(jsonDecode(source));

  factory ShipmentTypeModelResponse.fromMap(Map<String, dynamic> map) =>
      ShipmentTypeModelResponse(
        data: List<Map<String, dynamic>>.from(map['data'])
            .map(ShipmentTypeModel.fromMap)
            .toList(),
        error: map['error'] as int,
        message: map['message'] as String,
      );

  String toJson() => jsonEncode(toMap());
  Map<String, dynamic> toMap() => {
        'data': data.map((e) => e.toMap()).toList(),
        'error': error,
        'message': message,
      };
}
