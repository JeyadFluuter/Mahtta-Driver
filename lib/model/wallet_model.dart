import 'dart:convert';

class Wallet {
  final int id;
  final String balance;
  final String username;

  const Wallet({
    required this.id,
    required this.balance,
    required this.username,
  });

  factory Wallet.fromMap(Map<String, dynamic> m) => Wallet(
        id: m['id'] as int? ?? 0,
        balance: m['balance']?.toString() ?? "0.00",
        username: m['user_name']?.toString() ?? "",
      );

  Map<String, dynamic> toMap() =>
      {'id': id, 'balance': balance, 'user_name': username};

  factory Wallet.fromJson(String s) => Wallet.fromMap(jsonDecode(s));
  String toJson() => jsonEncode(toMap());
}

class WalletLog {
  final int id;
  final int walletId;
  final String amount;
  final String action;
  final String description;
  final String performedByType;
  final int performedById;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WalletLog({
    required this.id,
    required this.walletId,
    required this.amount,
    required this.action,
    required this.description,
    required this.performedByType,
    required this.performedById,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletLog.fromMap(Map<String, dynamic> m) => WalletLog(
        id: m['id'] as int? ?? 0,
        walletId: m['wallet_id'] as int? ?? 0,
        amount: m['amount']?.toString() ?? "0",
        action: m['action']?.toString() ?? "",
        description: m['description']?.toString() ?? "",
        performedByType: m['performed_by_type']?.toString() ?? "",
        performedById: m['performed_by_id'] as int? ?? 0,
        createdAt: m['created_at'] != null ? DateTime.tryParse(m['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
        updatedAt: m['updated_at'] != null ? DateTime.tryParse(m['updated_at'].toString()) ?? DateTime.now() : DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'wallet_id': walletId,
        'amount': amount,
        'action': action,
        'description': description,
        'performed_by_type': performedByType,
        'performed_by_id': performedById,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory WalletLog.fromJson(String s) => WalletLog.fromMap(jsonDecode(s));
  String toJson() => jsonEncode(toMap());
}

class WalletData {
  final Wallet wallet;
  final List<WalletLog> recentLogs;

  const WalletData({
    required this.wallet,
    required this.recentLogs,
  });

  factory WalletData.fromMap(Map<String, dynamic> m) => WalletData(
        wallet: m['wallet'] != null ? Wallet.fromMap(m['wallet'] as Map<String, dynamic>) : const Wallet(id: 0, balance: "0.00", username: ""),
        recentLogs: m['recent_logs'] != null ? (m['recent_logs'] as List<dynamic>)
            .map((e) => WalletLog.fromMap(e as Map<String, dynamic>))
            .toList() : [],
      );

  Map<String, dynamic> toMap() => {
        'wallet': wallet.toMap(),
        'recent_logs': recentLogs.map((e) => e.toMap()).toList(),
      };

  factory WalletData.fromJson(String s) => WalletData.fromMap(jsonDecode(s));
  String toJson() => jsonEncode(toMap());
}

class WalletResponse {
  final WalletData data;
  final int error;
  final String message;

  const WalletResponse({
    required this.data,
    required this.error,
    required this.message,
  });

  factory WalletResponse.fromMap(Map<String, dynamic> m) => WalletResponse(
        data: m['data'] != null ? WalletData.fromMap(m['data'] as Map<String, dynamic>) : const WalletData(wallet: Wallet(id: 0, balance: "0.00", username: ""), recentLogs: []),
        error: m['error'] as int? ?? 0,
        message: m['message']?.toString() ?? "",
      );

  factory WalletResponse.fromJson(String s) =>
      WalletResponse.fromMap(jsonDecode(s));

  Map<String, dynamic> toMap() => {
        'data': data.toMap(),
        'error': error,
        'message': message,
      };

  String toJson() => jsonEncode(toMap());
}
