class OrderResponse {
  final Order order;

  OrderResponse({
    required this.order,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    final orderJson = Map<String, dynamic>.from(json['order'] as Map? ?? {});
    
    // دمج بيانات السائق والزبون إذا كانت موجودة في جذر الرد (كما هو موضح في سجلات السيرفر)
    if (!orderJson.containsKey('driver') && json.containsKey('driver')) {
      print('🧠 Data Model: Merging driver from root into order object');
      orderJson['driver'] = json['driver'];
    }
    if (!orderJson.containsKey('customer') && json.containsKey('customer')) {
      print('🧠 Data Model: Merging customer from root into order object');
      orderJson['customer'] = json['customer'];
    }
    if (!orderJson.containsKey('status') && json.containsKey('status')) {
      print('🧠 Data Model: Merging status from root into order object');
      orderJson['status'] = json['status'];
    }

    return OrderResponse(
      order: Order.fromJson(orderJson),
    );
  }
}

class Order {
  final int id;
  final int customerId;
  final int driverId;
  final int vehicleTypeId;
  final int shipmentTypeId;
  final String shipmentTypeName;
  final String fromAddress;
  final String fromLat;
  final String fromLng;
  final String toAddress;
  final String toLat;
  final String toLng;
  final double distanceEstimated;
  final String priceEstimated;
  final String? description;
  final String? cargoWeight;
  final Status status;
  final VehicleType vehicleType;
  final Driver driver;
  final Customer customer;
  final String? paymentMethod;
  final String createdAt;
  final String updatedAt;
  final String? vehicleTypeImage;

  Order({
    required this.id,
    required this.customerId,
    required this.driverId,
    required this.vehicleTypeId,
    required this.shipmentTypeId,
    required this.shipmentTypeName,
    required this.fromAddress,
    required this.fromLat,
    required this.fromLng,
    required this.toAddress,
    required this.toLat,
    required this.toLng,
    required this.distanceEstimated,
    required this.priceEstimated,
    this.description,
    this.cargoWeight,
    required this.status,
    required this.vehicleType,
    required this.driver,
    required this.customer,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
    this.vehicleTypeImage,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return Order(
      id: json['id'] as int? ?? 0,
      customerId: json['customer_id'] as int? ?? 0,
      driverId: json['driver_id'] as int? ?? 0,
      vehicleTypeId: json['vehicle_type_id'] as int? ?? 0,
      shipmentTypeId: json['shipment_type_id'] as int? ?? 0,
      shipmentTypeName: json['shipment_type_name'] as String? ?? '',
      fromAddress: json['from_address'] as String? ?? '',
      fromLat: json['from_lat'] as String? ?? '',
      fromLng: json['from_lng'] as String? ?? '',
      toAddress: json['to_address'] as String? ?? '',
      toLat: json['to_lat'] as String? ?? '',
      toLng: json['to_lng'] as String? ?? '',
      distanceEstimated: parseDouble(json['distance_estimated']),
      priceEstimated: json['price_estimated']?.toString() ?? '',
      description: json['description'] as String?,
      cargoWeight: json['cargo_weight']?.toString(),
      status: Status.fromJson(json['status'] as Map<String, dynamic>? ?? {}),
      vehicleType: VehicleType.fromJson(
          json['vehicle_type'] as Map<String, dynamic>? ?? {}),
      driver: Driver.fromJson(json['driver'] as Map<String, dynamic>? ?? {}),
      customer:
          Customer.fromJson(json['customer'] as Map<String, dynamic>? ?? {}),
      paymentMethod: json['payment_method'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      vehicleTypeImage: json['vehicle_type_image'] as String?,
    );
  }
}

class Status {
  final int id;
  final String name;
  final String description;
  final String driverStatus;
  final String? icon;

  Status({
    required this.id,
    required this.name,
    required this.description,
    required this.driverStatus,
    this.icon,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      driverStatus: json['driver_status'] as String? ?? '',
      icon: json['icon'] as String?,
    );
  }
}

class VehicleType {
  final int id;
  final String name;
  final int vehicleCategoryId;
  final String description;
  final String baseFare;
  final String perKmRate;
  final String image;

  VehicleType({
    required this.id,
    required this.name,
    required this.vehicleCategoryId,
    required this.description,
    required this.baseFare,
    required this.perKmRate,
    required this.image,
  });

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      vehicleCategoryId: json['vehicle_category_id'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      baseFare: json['base_fare']?.toString() ?? '',
      perKmRate: json['per_km_rate']?.toString() ?? '',
      image: json['image'] as String? ?? '',
    );
  }
}

class Driver {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String? driverImage;
  final String? licenseFrontImage;
  final String? licenseBackImage;
  final String licenseNumber;
  final String licenseType;
  final String licenseExpiry;
  final int isActive;
  final int isVerified;
  final String status;
  final double averageRating;

  final String? currentLat;
  final String? currentLng;

  Driver({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    this.driverImage,
    this.licenseFrontImage,
    this.licenseBackImage,
    required this.licenseNumber,
    required this.licenseType,
    required this.licenseExpiry,
    required this.isActive,
    required this.isVerified,
    required this.status,
    required this.averageRating,
    this.currentLat,
    this.currentLng,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return Driver(
      id: json['id'] as int? ?? 0,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      driverImage: json['driver_image'] as String?,
      licenseFrontImage: json['license_front_image'] as String?,
      licenseBackImage: json['license_back_image'] as String?,
      licenseNumber: json['license_number'] as String? ?? '',
      licenseType: json['license_type'] as String? ?? '',
      licenseExpiry: json['license_expiry'] as String? ?? '',
      isActive: json['is_active'] as int? ?? 0,
      isVerified: json['is_verified'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      averageRating: (json['average_rating'] != null)
          ? parseDouble(json['average_rating'])
          : 0.0,
      currentLat: (json['current_lat'] ?? json['lat'] ?? json['latitude'])?.toString(),
      currentLng: (json['current_lng'] ?? json['lng'] ?? json['longitude'])?.toString(),
    );
  }
}

class Customer {
  final int id;
  final String firstName;
  final String lastName;
  final String? city;
  final String? image;
  final String? email;
  final String phone;
  final int isActive;
  final int isVerified;

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.city,
    this.image,
    this.email,
    required this.phone,
    required this.isActive,
    required this.isVerified,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int? ?? 0,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      city: json['city'] as String?,
      image: json['image'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String? ?? '',
      isActive: json['is_active'] as int? ?? 0,
      isVerified: json['is_verified'] as int? ?? 0,
    );
  }
}
