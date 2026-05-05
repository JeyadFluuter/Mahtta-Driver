import 'dart:convert';

class RejectionOrdersModel {
  final int orderId;
  RejectionOrdersModel({required this.orderId});

  factory RejectionOrdersModel.fromMap(Map<String, dynamic> json) {
    return RejectionOrdersModel(
      orderId: json["order_id"] ?? json["id"] ?? 0,
    );
  }

  factory RejectionOrdersModel.fromAny(dynamic any) {
    if (any is Map<String, dynamic>) {
      return RejectionOrdersModel.fromMap(any);
    }
    if (any is List) {
      if (any.isEmpty) return RejectionOrdersModel(orderId: 0);
      final first = any.first;
      if (first is Map<String, dynamic>) {
        return RejectionOrdersModel.fromMap(first);
      }
      if (first is int) return RejectionOrdersModel(orderId: first);
      if (first is String) {
        final parsed = _tryDecode(first);
        return RejectionOrdersModel.fromAny(parsed);
      }
      return RejectionOrdersModel(orderId: 0);
    }
    if (any is String) {
      final parsed = _tryDecode(any);
      return RejectionOrdersModel.fromAny(parsed);
    }
    return RejectionOrdersModel(orderId: 0);
  }

  static dynamic _tryDecode(String s) {
    try {
      return jsonDecode(s);
    } catch (_) {
      return {};
    }
  }

  Map<String, dynamic> toMap() => {"order_id": orderId};
}
