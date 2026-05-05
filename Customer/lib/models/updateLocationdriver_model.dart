class UpdatelocationdriverModel {
  final double? lat;
  final double? lng;

  UpdatelocationdriverModel({
    required this.lat,
    required this.lng,
  });

  factory UpdatelocationdriverModel.fromJson(Map<String, dynamic> json) =>
      UpdatelocationdriverModel(
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
      };
}
