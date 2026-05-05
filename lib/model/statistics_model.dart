import 'dart:convert';

class StatisticsModel {
  final String period;
  final DateTime from;
  final DateTime to;
  final int orders;
  final double revenue;
  final double avgOrderValue;

  StatisticsModel({
    required this.period,
    required this.from,
    required this.to,
    required this.orders,
    required this.revenue,
    required this.avgOrderValue,
  });

  factory StatisticsModel.fromMap(Map<String, dynamic> map) => StatisticsModel(
        period: map['period'] as String,
        from: DateTime.parse(map['from']),
        to: DateTime.parse(map['to']),
        orders: map['orders'] as int,
        revenue: (map['revenue'] as num).toDouble(),
        avgOrderValue: (map['avg_order_value'] as num).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'period': period,
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
        'orders': orders,
        'revenue': revenue,
        'avg_order_value': avgOrderValue,
      };
}

class DriverStatsResponse {
  final StatisticsModel data;
  final int error;
  final String message;

  DriverStatsResponse({
    required this.data,
    required this.error,
    required this.message,
  });

  factory DriverStatsResponse.fromJson(String source) =>
      DriverStatsResponse.fromMap(jsonDecode(source));

  factory DriverStatsResponse.fromMap(Map<String, dynamic> map) =>
      DriverStatsResponse(
        data: StatisticsModel.fromMap(map['data']),
        error: map['error'] as int,
        message: map['message'] as String,
      );
}
