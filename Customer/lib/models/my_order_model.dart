import 'dart:convert';

List<MyOrder> myordersFromJson(String str) {
  final jsonData = json.decode(str);
  final list = jsonData['data']?['data'];
  if (list is! List) {
    throw Exception('لم أجد مصفوفة الطلبات داخل data.data');
  }
  return list.map<MyOrder>((e) => MyOrder.fromJson(e)).toList();
}

String myordersFromJsonModelToJson(List<MyOrder> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MyOrder {
  final int? id;
  final int? customerId;
  final int? driverId;
  final int? vehicleTypeId;
  final int? shipmentTypeId;
  final String? shipmentTypeName;
  final String? cargoDescription;
  final String? fromAddress;
  final String? fromLat;
  final String? fromLng;
  final String? toAddress;
  final String? toLat;
  final String? toLng;
  final double? distanceEstimated;
  final double? priceEstimated;
  final String? description;
  final double? cargoWeight;
  final String? paymentMethod;
  final OrderStatus? status;
  final String? createdAt;
  final String? updatedAt;

  MyOrder({
    this.id,
    this.customerId,
    this.driverId,
    this.vehicleTypeId,
    this.shipmentTypeId,
    this.shipmentTypeName,
    this.cargoDescription,
    this.fromAddress,
    this.fromLat,
    this.fromLng,
    this.toAddress,
    this.toLat,
    this.toLng,
    this.distanceEstimated,
    this.priceEstimated,
    this.description,
    this.cargoWeight,
    this.paymentMethod,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory MyOrder.fromJson(Map<String, dynamic> json) => MyOrder(
        id: json['id'],
        customerId: json['customer_id'],
        driverId: json['driver_id'],
        vehicleTypeId: json['vehicle_type_id'],
        shipmentTypeId: json['shipment_type_id'],
        shipmentTypeName: json['shipment_type_name'],
        cargoDescription: json['cargo_description'],
        fromAddress: json['from_address'],
        fromLat: json['from_lat'],
        fromLng: json['from_lng'],
        toAddress: json['to_address'],
        toLat: json['to_lat'],
        toLng: json['to_lng'],
        distanceEstimated: _toDouble(json['distance_estimated']),
        priceEstimated: _toDouble(json['price_estimated']),
        description: json['description'],
        cargoWeight: _toDouble(json['cargo_weight']),
        paymentMethod: json['payment_method'],
        status: json['status'] != null
            ? OrderStatus.fromJson(json['status'])
            : null,
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'driver_id': driverId,
        'vehicle_type_id': vehicleTypeId,
        'shipment_type_id': shipmentTypeId,
        'shipment_type_name': shipmentTypeName,
        'cargo_description': cargoDescription,
        'from_address': fromAddress,
        'from_lat': fromLat,
        'from_lng': fromLng,
        'to_address': toAddress,
        'to_lat': toLat,
        'to_lng': toLng,
        'distance_estimated': distanceEstimated,
        'price_estimated': priceEstimated,
        'description': description,
        'cargo_weight': cargoWeight,
        'payment_method': paymentMethod,
        'status': status?.toJson(),
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  static double? _toDouble(dynamic v) =>
      v == null ? null : double.tryParse(v.toString());
}

class OrderStatus {
  final int? id;
  final String? name;
  final String? description;
  final String? driverStatus;
  final String? icon;

  OrderStatus({
    this.id,
    this.name,
    this.description,
    this.driverStatus,
    this.icon,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) => OrderStatus(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        driverStatus: json['driver_status'],
        icon: json['icon'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'driver_status': driverStatus,
        'icon': icon,
      };
}
