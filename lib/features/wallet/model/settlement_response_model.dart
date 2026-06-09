class WalletSummaryResponse {
  final bool status;
  final WalletSummaryData? data;

  WalletSummaryResponse({required this.status, this.data});

  factory WalletSummaryResponse.fromJson(Map<String, dynamic> json) {
    final d = json['data'] as Map<String, dynamic>?;
    return WalletSummaryResponse(
      status: json['status'] ?? false,
      data: d != null ? WalletSummaryData.fromJson(d) : null,
    );
  }
}

class WalletSummaryData {
  final double totalAmount;
  final double unsettledAmount;
  final double settledAmount;
  final double filteredAmount;
  final int transactionCount;
  final int unsettledCount;
  final int settledCount;

  WalletSummaryData({
    required this.totalAmount,
    required this.unsettledAmount,
    required this.settledAmount,
    required this.filteredAmount,
    required this.transactionCount,
    required this.unsettledCount,
    required this.settledCount,
  });

  factory WalletSummaryData.fromJson(Map<String, dynamic> json) {
    return WalletSummaryData(
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      unsettledAmount: double.tryParse(json['unsettled_amount']?.toString() ?? '0') ?? 0,
      settledAmount: double.tryParse(json['settled_amount']?.toString() ?? '0') ?? 0,
      filteredAmount: double.tryParse(json['filtered_amount']?.toString() ?? '0') ?? 0,
      transactionCount: json['transaction_count'] ?? 0,
      unsettledCount: json['unsettled_count'] ?? 0,
      settledCount: json['settled_count'] ?? 0,
    );
  }

  double get lifetimeTotal => totalAmount;
}

class WalletTransactionItem {
  final int id;
  final double amount;
  final String creditDebit;
  final String? remark;
  final String? via;
  final String settlementStatus;
  final String? sourceType;
  final DateTime createdAt;
  final String fromUserName;
  final String fromUserProfile;

  WalletTransactionItem({
    required this.id,
    required this.amount,
    required this.creditDebit,
    this.remark,
    this.via,
    required this.settlementStatus,
    this.sourceType,
    required this.createdAt,
    this.fromUserName = '',
    this.fromUserProfile = '',
  });

  factory WalletTransactionItem.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['created_at'] ?? '');
    } catch (_) {
      parsedDate = DateTime.now();
    }
    return WalletTransactionItem(
      id: json['id'] ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      creditDebit: json['credit_debit'] ?? 'credit',
      remark: json['remark'],
      via: json['via'],
      settlementStatus: json['settlement_status'] ?? 'pending',
      sourceType: json['source_type'],
      createdAt: parsedDate,
      fromUserName: json['from_user_name'] ?? '',
      fromUserProfile: json['from_user_profile'] ?? '',
    );
  }

  bool get isSettled => settlementStatus == 'settled';
}

class SettlementHistoryItem {
  final int id;
  final double totalAmount;
  final String transactionIds;
  final DateTime createdAt;

  SettlementHistoryItem({
    required this.id,
    required this.totalAmount,
    required this.transactionIds,
    required this.createdAt,
  });

  factory SettlementHistoryItem.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['created_at'] ?? '');
    } catch (_) {
      parsedDate = DateTime.now();
    }
    return SettlementHistoryItem(
      id: json['id'] ?? 0,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      transactionIds: json['transaction_ids'] ?? '[]',
      createdAt: parsedDate,
    );
  }
}
