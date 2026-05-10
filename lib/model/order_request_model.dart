class OrderData {
  final int id;
  final String fromAddress;
  final String toAddress;
  final String cargoDescription;
  final String distanceKm;
  final String priceLyd;
  final String commissionLyd;

  final String cargoImage;
  final String cargoDesc;

  OrderData({
    required this.id,
    required this.fromAddress,
    required this.toAddress,
    required this.cargoDescription,
    required this.distanceKm,
    required this.priceLyd,
    required this.commissionLyd,
    this.cargoImage = "",
    this.cargoDesc = "",
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    final int id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0;
    final price = double.tryParse(json['price_estimated']?.toString() ?? '0') ?? 0.0;
    final commission = json['commission_amount'] != null
        ? double.tryParse(json['commission_amount'].toString()) ?? 0.0
        : price * 0.2;

    return OrderData(
      id: id,
      fromAddress: json['from_address']?.toString() ?? '',
      toAddress: json['to_address']?.toString() ?? '',
      distanceKm: (json['distance_estimated'] ?? "0").toString(),
      priceLyd: price.toString(),
      commissionLyd: commission.toStringAsFixed(2),
      cargoDescription: (json['shipment_type_name'] ?? json['shipment_type'] ?? "").toString(),
      cargoImage: json['cargo_image']?.toString() ?? "",
      cargoDesc: json['cargo_description']?.toString() ?? "",
    );
  }
}
