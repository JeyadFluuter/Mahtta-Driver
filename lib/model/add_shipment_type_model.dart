import 'dart:convert';

class AddShipmentTypeModel {
  final int id;

  AddShipmentTypeModel({
    required this.id,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddShipmentTypeModel &&
          runtimeType == other.runtimeType &&
          id == other.id;
  @override
  int get hashCode => id.hashCode;

  factory AddShipmentTypeModel.fromMap(Map<String, dynamic> map) =>
      AddShipmentTypeModel(
        id: map['id'] as int,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
      };
}

class AddShipmentTypeModelResponse {
  final List<AddShipmentTypeModel> data;
  final int error;
  final String message;

  AddShipmentTypeModelResponse({
    required this.data,
    required this.error,
    required this.message,
  });

  factory AddShipmentTypeModelResponse.fromJson(String source) =>
      AddShipmentTypeModelResponse.fromMap(jsonDecode(source));

  factory AddShipmentTypeModelResponse.fromMap(Map<String, dynamic> map) =>
      AddShipmentTypeModelResponse(
        data: List<Map<String, dynamic>>.from(map['data'])
            .map(AddShipmentTypeModel.fromMap)
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
