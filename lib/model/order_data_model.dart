class OrderResponse {
  final Order order;
  final Customer customer;
  final Driver driver;
  final Status status;

  OrderResponse({
    required this.order,
    required this.customer,
    required this.driver,
    required this.status,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    final orderJson =
        (json['order'] is Map) ? json['order'] as Map<String, dynamic> : json;

    return OrderResponse(
      order: Order.fromJson(orderJson),
      customer:
          Customer.fromJson(orderJson['customer'] ?? json['customer'] ?? {}),
      driver: Driver.fromJson(orderJson['driver'] ?? json['driver'] ?? {}),
      status: Status.fromJson(orderJson['status'] ?? {}),
    );
  }

  OrderResponse copyWith({
    Order? order,
    Customer? customer,
    Driver? driver,
    Status? status,
  }) {
    return OrderResponse(
      order: order ?? this.order,
      customer: customer ?? this.customer,
      driver: driver ?? this.driver,
      status: status ?? this.status,
    );
  }
}

class Order {
  final int id;
  final String fromAddress;
  final String toAddress;
  final String fromLat;
  final String fromLng;
  final String toLat;
  final String toLng;
  final double distanceEstimated;
  final String priceEstimated;
  final String shipmentType;

  Order({
    required this.id,
    required this.fromAddress,
    required this.toAddress,
    required this.fromLat,
    required this.fromLng,
    required this.toLat,
    required this.toLng,
    required this.distanceEstimated,
    required this.priceEstimated,
    required this.shipmentType,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return Order(
      id: json['id'] ?? 0,
      fromAddress: json['from_address'] as String? ?? '',
      fromLat: json['from_lat'] as String? ?? '',
      fromLng: json['from_lng'] as String? ?? '',
      toAddress: json['to_address'] as String? ?? '',
      toLat: json['to_lat'] as String? ?? '',
      toLng: json['to_lng'] as String? ?? '',
      distanceEstimated: parseDouble(json['distance_estimated']),
      priceEstimated: json['price_estimated']?.toString() ?? '',
      shipmentType: json['shipment_type'] ?? '',
    );
  }
}

class Customer {
  final String firstName;
  final String lastName;
  final String phone;

  Customer({
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        firstName: json['first_name'] ?? '',
        lastName: json['last_name'] ?? '',
        phone: json['phone'] ?? '',
      );
}

class Driver {
  final String currentLat;
  final String currentLng;
  final String phone;

  Driver({
    required this.currentLat,
    required this.currentLng,
    required this.phone,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        currentLat: json['current_lat']?.toString() ?? '',
        currentLng: json['current_lng']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
      );
}

class Status {
  final int id;
  final String name;
  final String description;
  final String driverStatus;

  Status({
    required this.id,
    required this.name,
    required this.description,
    required this.driverStatus,
  });

  factory Status.fromJson(Map<String, dynamic> json) => Status(
        id: json['id'] ?? 0,
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        driverStatus: json['driver_status']?.toString() ?? '',
      );
}
