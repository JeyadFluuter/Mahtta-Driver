class RatingResponse {
  final int error;
  final String message;
  final RatingData data;

  RatingResponse({
    required this.error,
    required this.message,
    required this.data,
  });

  factory RatingResponse.fromJson(Map<String, dynamic> json) {
    return RatingResponse(
      error: json['error'] ?? 1,
      message: json['message'] ?? '',
      data: RatingData.fromJson(json['data'] ?? {}),
    );
  }
}

class RatingData {
  final int id;
  final int orderId;
  final int customerId;
  final int driverId;
  final String rating;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  RatingData({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.driverId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RatingData.fromJson(Map<String, dynamic> json) {
    return RatingData(
      id: json['id'],
      orderId: json['order_id'] as int,
      customerId: json['customer_id'],
      driverId: json['driver_id'],
      rating: json['rating']?.toString() ?? '',
      comment: json['comment']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
