import 'dart:convert';

class ProfitSummary {
  final double totalEarnings;
  final int totalOrders;
  final double avgPerOrder;

  ProfitSummary({
    required this.totalEarnings,
    required this.totalOrders,
    required this.avgPerOrder,
  });

  factory ProfitSummary.fromMap(Map<String, dynamic> map) => ProfitSummary(
        totalEarnings: (map['total_earnings'] as num).toDouble(),
        totalOrders: map['total_orders'] as int,
        avgPerOrder: (map['avg_per_order'] as num).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'total_earnings': totalEarnings,
        'total_orders': totalOrders,
        'avg_per_order': avgPerOrder,
      };
}

class ProfitSummaryResponse {
  final ProfitSummary data;
  final int error;
  final String message;

  ProfitSummaryResponse({
    required this.data,
    required this.error,
    required this.message,
  });

  factory ProfitSummaryResponse.fromJson(String source) =>
      ProfitSummaryResponse.fromMap(jsonDecode(source));

  factory ProfitSummaryResponse.fromMap(Map<String, dynamic> map) =>
      ProfitSummaryResponse(
        data: ProfitSummary.fromMap(map['data']),
        error: map['error'] as int,
        message: map['message'] as String,
      );

  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() => {
        'data': data.toMap(),
        'error': error,
        'message': message,
      };
}
