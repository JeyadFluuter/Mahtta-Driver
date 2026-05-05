import 'dart:convert';

import 'package:biadgo/constants/apiUrl.dart';

List<dataShipmentTypes> dataShipmentTypesFromJson(String str) {
  final jsonData = json.decode(str);
  final dataList = jsonData["data"] as List;

  // نحوّل كل عنصر في المصفوفة إلى كائن DataLocation
  return dataList.map((item) => dataShipmentTypes.fromJson(item)).toList();
}

String dataShipmentTypesModelToJson(List<dataShipmentTypes> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class dataShipmentTypes {
  final int id;
  final String? name;
  final String? description;
  final String? image;
  final int isAutoDispose;

  dataShipmentTypes({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.isAutoDispose,
  });

  factory dataShipmentTypes.fromJson(Map<String, dynamic> json) =>
      dataShipmentTypes(
        id: json["id"] ?? 0,
        name: json["name"] ?? '',
        description: json["description"] ?? '',
        image: json["image"] != null ? "$ImageUrl${json['image']}" : '',
        isAutoDispose: json["is_auto_dispose"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "image": image,
        "is_auto_dispose": isAutoDispose,
      };
}
