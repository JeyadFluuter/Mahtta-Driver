import 'dart:convert';

List<DataLocation> locationFromJson(String str) {
  final jsonData = json.decode(str);
  final list = jsonData['data']?['data'];
  if (list is! List) {
    throw Exception('لم أجد مصفوفة الطلبات داخل data.data');
  }
  return list.map<DataLocation>((e) => DataLocation.fromJson(e)).toList();
}

String locationModelToJson(List<DataLocation> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataLocation {
  final int id;
  final String? sourceAddress;
  final String? sourceLat;
  final String? sourceLng;
  final int isDefault;
  final String? destinationAddress;
  final String? destinationLat;
  final String? destinationLng;

  DataLocation({
    required this.id,
    required this.sourceAddress,
    required this.sourceLat,
    required this.sourceLng,
    required this.isDefault,
    required this.destinationAddress,
    required this.destinationLat,
    required this.destinationLng,
  });

  factory DataLocation.fromJson(Map<String, dynamic> json) => DataLocation(
        id: json["id"] ?? 0,
        sourceAddress: json["source_address"] ?? '',
        sourceLat: json["source_lat"] ?? '',
        sourceLng: json["source_lng"] ?? '',
        isDefault: json["is_default"] ?? 0,
        destinationAddress: json["destination_address"]?.toString() ?? '',
        destinationLat: json["destination_lat"] ?? '',
        destinationLng: json["destination_lng"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "source_address": sourceAddress,
        "source_lat": sourceLat,
        "source_lng": sourceLng,
        "is_default": isDefault,
        "destination_address": destinationAddress,
        "destination_lat": destinationLat,
        "destination_lng": destinationLng,
      };
}
