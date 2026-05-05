class DataEsimate {
  final int? addressId;
  final String? sourceAddress;
  final String? sourceLat;
  final String? sourceLng;
  final String? cargoDescription;
  final String? destinationAddress;
  final String? destinationLat;
  final String? destinationLng;
  final int shipmentTypeId;
  final int vehicleTypeId;
  final double? distance;
  final double? priceEstimated;
  final String? estimatedTime;
  final int cargoWeight;
  final int autoDispose;
  DataEsimate({
    required this.addressId,
    required this.sourceAddress,
    required this.sourceLat,
    required this.sourceLng,
    required this.cargoDescription,
    required this.destinationAddress,
    required this.destinationLat,
    required this.destinationLng,
    required this.shipmentTypeId,
    required this.vehicleTypeId,
    required this.distance,
    required this.priceEstimated,
    required this.estimatedTime,
    required this.cargoWeight,
    required this.autoDispose,
  });

  factory DataEsimate.fromJson(Map<String, dynamic> json) {
    return DataEsimate(
        addressId: json["address_id"] ?? 0,
        sourceAddress: json["source_address"] ?? '',
        sourceLat: json["source_lat"] ?? '',
        sourceLng: json["source_lng"] ?? '',
        cargoDescription: json["cargo_description"] ?? '',
        destinationAddress: json["destination_address"]?.toString() ?? '',
        destinationLat: json["destination_lat"] ?? '',
        destinationLng: json["destination_lng"] ?? '',
        shipmentTypeId: json["shipment_type_id"] ?? 0,
        vehicleTypeId: json["vehicle_type_id"] ?? 0,
        distance: json["delivery_info"]?["distance"]?.toDouble() ?? 0.0,
        priceEstimated:
            json["delivery_info"]?["price_estimated"]?.toDouble() ?? 0.0,
        estimatedTime: json["delivery_info"]?["estimated_time"] ?? '',
        cargoWeight: json["cargo_weight"] ?? 0,
        autoDispose: json["auto_dispose"] ?? 0);
  }

  Map<String, dynamic> toJson() => {
        "address_id": addressId,
        "source_address": sourceAddress,
        "source_lat": sourceLat,
        "source_lng": sourceLng,
        "cargo_description": cargoDescription,
        "destination_address": destinationAddress,
        "destination_lat": destinationLat,
        "destination_lng": destinationLng,
        "shipment_type_id": shipmentTypeId,
        "vehicle_type_id": vehicleTypeId,
        "distance": distance,
        "price_estimated": priceEstimated,
        "estimated_time": estimatedTime,
        "cargo_weight": cargoWeight,
        "auto_dispose": autoDispose,
      };
}
