class OrderData {
  final int id;
  final String fromAddress;
  final String toAddress;
  final String cargoDescription;
  final String distanceKm;
  final String priceLyd;
  final String commissionLyd;

  OrderData({
    required this.id,
    required this.fromAddress,
    required this.toAddress,
    required this.cargoDescription,
    required this.distanceKm,
    required this.priceLyd,
    required this.commissionLyd,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    final price = double.tryParse(json['price_estimated'].toString()) ?? 0.0;
    final commission = json['commission_amount'] != null
        ? double.tryParse(json['commission_amount'].toString()) ?? 0.0
        : price * 0.2;

    return OrderData(
      id: json['id'] as int,
      fromAddress: json['from_address'] as String,
      toAddress: json['to_address'] as String,
      distanceKm: (json['distance_estimated'] ?? "0").toString(),
      priceLyd: price.toString(),
      commissionLyd: commission.toStringAsFixed(2),
      cargoDescription: json['shipment_type_name'] as String? ?? "",
    );
  }
}
