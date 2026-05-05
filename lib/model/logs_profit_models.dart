import 'dart:convert';

class LogsProfitModels {
  final EarningDataWrapper data;
  final int error;
  final String message;

  LogsProfitModels({
    required this.data,
    required this.error,
    required this.message,
  });

  factory LogsProfitModels.fromJson(String str) =>
      LogsProfitModels.fromMap(json.decode(str));

  factory LogsProfitModels.fromMap(Map<String, dynamic> json) =>
      LogsProfitModels(
        data: EarningDataWrapper.fromMap(json['data']),
        error: json['error'] ?? 0,
        message: json['message'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'data': data.toMap(),
        'error': error,
        'message': message,
      };
}

class EarningDataWrapper {
  final List<EarningRecord> data;
  final Pagination pagination;

  EarningDataWrapper({
    required this.data,
    required this.pagination,
  });

  factory EarningDataWrapper.fromMap(Map<String, dynamic> json) =>
      EarningDataWrapper(
        data: List<EarningRecord>.from(
          (json['data'] ?? []).map((x) => EarningRecord.fromMap(x)),
        ),
        pagination: Pagination.fromMap(json['pagination']),
      );

  Map<String, dynamic> toMap() => {
        'data': List<dynamic>.from(data.map((x) => x.toMap())),
        'pagination': pagination.toMap(),
      };
}

class EarningRecord {
  final int id;
  final int orderId;
  final DateTime createdAt;
  final double earning;
  final double orderCost;
  final double commissionAmount;
  final double distance;

  EarningRecord({
    required this.id,
    required this.orderId,
    required this.createdAt,
    required this.earning,
    required this.orderCost,
    required this.commissionAmount,
    required this.distance,
  });

  factory EarningRecord.fromMap(Map<String, dynamic> json) => EarningRecord(
        id: json['id'],
        orderId: json['order_id'],
        createdAt: DateTime.parse(json['created_at']),
        earning: double.tryParse(json['earning'].toString()) ?? 0.0,
        orderCost: double.tryParse(json['order_cost'].toString()) ?? 0.0,
        commissionAmount:
            double.tryParse(json['commission_amount'].toString()) ?? 0.0,
        distance: (json['distance'] as num).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'order_id': orderId,
        'created_at': createdAt.toIso8601String(),
        'earning': earning,
        'order_cost': orderCost,
        'commission_amount': commissionAmount,
        'distance': distance,
      };
}

class Pagination {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;

  Pagination({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  factory Pagination.fromMap(Map<String, dynamic> json) => Pagination(
        total: json['total'],
        perPage: json['per_page'],
        currentPage: json['current_page'],
        lastPage: json['last_page'],
      );

  Map<String, dynamic> toMap() => {
        'total': total,
        'per_page': perPage,
        'current_page': currentPage,
        'last_page': lastPage,
      };
}
