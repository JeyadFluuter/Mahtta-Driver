class DataConfirmOrder {
  final int orderId;
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
  final String paymentMethod;
  final int autoDispose;

  DataConfirmOrder({
    required this.orderId,
    this.addressId = 0,
    this.sourceAddress = '',
    this.sourceLat = '',
    this.sourceLng = '',
    this.cargoDescription = '',
    this.destinationAddress = '',
    this.destinationLat = '',
    this.destinationLng = '',
    this.shipmentTypeId = 0,
    this.vehicleTypeId = 0,
    this.paymentMethod = '',
    this.autoDispose = 0,
  });

  factory DataConfirmOrder.fromJson(Map<String, dynamic> json) {
    return DataConfirmOrder(
      orderId: (json["data"]?["order"]?["id"] ?? json["id"] ?? 0) as int,
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
      paymentMethod: json["deliveryInfo"]?["paymentMethod"]?.toString() ?? '',
      autoDispose: json["autoDispose"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": orderId,
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
        "payment_method": paymentMethod,
        "auto_dispose": autoDispose,
      };
}
