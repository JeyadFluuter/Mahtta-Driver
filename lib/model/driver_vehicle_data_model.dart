import 'dart:convert';

class DriverVehicleDataModel {
  final int vehicleTypeId;
  final String plateNumber;
  final String chassisNumber;
  final String vehicleBrand;
  final String vehicleColor;
  final String vehicleBrochure;
  final String model;
  final String capacity;
  final bool isApproved;
  final String insuranceDocument;
  final String vehicleFrontImage;
  final String vehicleBackImage;
  final String vehicleRightSideImage;
  final String vehicleLeftSideImage;
  final String vehicleInsideImage;
  final String vehicleTrunkImage;
  final String? vehicleTypeName;
  final String? vehicleTypeImage;

  DriverVehicleDataModel({
    required this.vehicleTypeId,
    required this.plateNumber,
    required this.chassisNumber,
    required this.vehicleBrand,
    required this.vehicleColor,
    required this.vehicleBrochure,
    required this.model,
    required this.capacity,
    required this.isApproved,
    required this.insuranceDocument,
    required this.vehicleFrontImage,
    required this.vehicleBackImage,
    required this.vehicleRightSideImage,
    required this.vehicleLeftSideImage,
    required this.vehicleInsideImage,
    required this.vehicleTrunkImage,
    this.vehicleTypeName,
    this.vehicleTypeImage,
  });

  factory DriverVehicleDataModel.fromJson(String str) =>
      DriverVehicleDataModel.fromMap(json.decode(str));

  factory DriverVehicleDataModel.fromMap(Map<String, dynamic> json) =>
      DriverVehicleDataModel(
        vehicleTypeId: int.tryParse(json["vehicle_type_id"]?.toString() ?? '0') ?? 0,
        plateNumber: json["plate_number"] ?? '',
        chassisNumber: json["chassis_number"] ?? '',
        vehicleBrand: json["vehicle_brand"] ?? '',
        vehicleColor: json["vehicle_color"] ?? '',
        vehicleBrochure: json["vehicle_brochure"] ?? '',
        model: json["model"]?.toString() ?? '',
        capacity: json["capacity"]?.toString() ?? '',
        isApproved: json["is_approved"] == 1 || json["is_approved"] == true,
        insuranceDocument: json["insurance_document"] ?? '',
        vehicleFrontImage: json["vehicle_front_image"] ?? '',
        vehicleBackImage: json["vehicle_back_image"] ?? '',
        vehicleRightSideImage: json["vehicle_right_side_image"] ?? '',
        vehicleLeftSideImage: json["vehicle_left_side_image"] ?? '',
        vehicleInsideImage: json["vehicle_inside_image"] ?? '',
        vehicleTrunkImage: json["vehicle_trunk_image"] ?? '',
        vehicleTypeName: json["vehicle_type"]?["name"],
        vehicleTypeImage: json["vehicle_type"]?["image"],
      );

  Map<String, dynamic> toMap() => {
        "vehicle_type_id": vehicleTypeId,
        "plate_number": plateNumber,
        "chassis_number": chassisNumber,
        "vehicle_brand": vehicleBrand,
        "vehicle_color": vehicleColor,
        "vehicle_brochure": vehicleBrochure,
        "model": model,
        "capacity": capacity,
        "is_approved": isApproved,
        "insurance_document": insuranceDocument,
        "vehicle_front_image": vehicleFrontImage,
        "vehicle_back_image": vehicleBackImage,
        "vehicle_right_side_image": vehicleRightSideImage,
        "vehicle_left_side_image": vehicleLeftSideImage,
        "vehicle_inside_image": vehicleInsideImage,
        "vehicle_trunk_image": vehicleTrunkImage,
        "vehicle_type_name": vehicleTypeName,
        "vehicle_type_image": vehicleTypeImage,
      };
}
