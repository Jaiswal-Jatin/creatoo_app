class BusinessSettlementData {
  final double totalAmount;
  final double settledAmount;
  final double pendingAmount;

  BusinessSettlementData({
    this.totalAmount = 0,
    this.settledAmount = 0,
    this.pendingAmount = 0,
  });

  factory BusinessSettlementData.fromJson(Map<String, dynamic> json) {
    return BusinessSettlementData(
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      settledAmount: double.tryParse(json['settled_amount']?.toString() ?? '0') ?? 0,
      pendingAmount: double.tryParse(json['pending_amount']?.toString() ?? '0') ?? 0,
    );
  }
}

class CombinedSettlementData {
  final double totalAmount;
  final double settledAmount;
  final double pendingAmount;
  final double billPending;
  final double bookingPending;
  final double billTotal;
  final double bookingTotal;

  CombinedSettlementData({
    this.totalAmount = 0,
    this.settledAmount = 0,
    this.pendingAmount = 0,
    this.billPending = 0,
    this.bookingPending = 0,
    this.billTotal = 0,
    this.bookingTotal = 0,
  });

  factory CombinedSettlementData.fromJson(Map<String, dynamic> json) {
    return CombinedSettlementData(
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      settledAmount: double.tryParse(json['settled_amount']?.toString() ?? '0') ?? 0,
      pendingAmount: double.tryParse(json['pending_amount']?.toString() ?? '0') ?? 0,
      billPending: double.tryParse(json['bill_pending']?.toString() ?? '0') ?? 0,
      bookingPending: double.tryParse(json['booking_pending']?.toString() ?? '0') ?? 0,
      billTotal: double.tryParse(json['bill_total']?.toString() ?? '0') ?? 0,
      bookingTotal: double.tryParse(json['booking_total']?.toString() ?? '0') ?? 0,
    );
  }
}

class SettlementRecordItem {
  final int id;
  final double amount;
  final double billAmount;
  final double bookingAmount;
  final String type;
  final double remainingAfter;
  final String? notes;
  final String createdAt;

  SettlementRecordItem({
    required this.id,
    required this.amount,
    this.billAmount = 0,
    this.bookingAmount = 0,
    this.type = 'combined',
    required this.remainingAfter,
    this.notes,
    required this.createdAt,
  });

  factory SettlementRecordItem.fromJson(Map<String, dynamic> json) {
    return SettlementRecordItem(
      id: json['id'] ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      billAmount: double.tryParse(json['bill_amount']?.toString() ?? '0') ?? 0,
      bookingAmount: double.tryParse(json['booking_amount']?.toString() ?? '0') ?? 0,
      type: json['type'] ?? 'combined',
      remainingAfter: double.tryParse(json['remaining_after']?.toString() ?? '0') ?? 0,
      notes: json['notes'],
      createdAt: json['created_at'] ?? '',
    );
  }
}

class BusinessSettlementResponse {
  final bool status;
  final BusinessSettlementData? data;

  BusinessSettlementResponse({required this.status, this.data});

  factory BusinessSettlementResponse.fromJson(Map<String, dynamic> json) {
    return BusinessSettlementResponse(
      status: json['status'] ?? false,
      data: json['data'] != null ? BusinessSettlementData.fromJson(json['data']) : null,
    );
  }
}

class CombinedSettlementResponse {
  final bool status;
  final CombinedSettlementData? data;

  CombinedSettlementResponse({required this.status, this.data});

  factory CombinedSettlementResponse.fromJson(Map<String, dynamic> json) {
    return CombinedSettlementResponse(
      status: json['status'] ?? false,
      data: json['data'] != null ? CombinedSettlementData.fromJson(json['data']) : null,
    );
  }
}

class SettlementRecordsResponse {
  final bool status;
  final List<SettlementRecordItem> data;

  SettlementRecordsResponse({required this.status, required this.data});

  factory SettlementRecordsResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>?) ?? [];
    return SettlementRecordsResponse(
      status: json['status'] ?? false,
      data: list.map((e) => SettlementRecordItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class AdminUnsettledBusiness {
  final int businessId;
  final String businessName;
  final double totalAmount;
  final double settledAmount;
  final double pendingAmount;

  AdminUnsettledBusiness({
    required this.businessId,
    required this.businessName,
    required this.totalAmount,
    required this.settledAmount,
    required this.pendingAmount,
  });

  factory AdminUnsettledBusiness.fromJson(Map<String, dynamic> json) {
    return AdminUnsettledBusiness(
      businessId: json['business_id'] ?? 0,
      businessName: json['business_name'] ?? '',
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      settledAmount: double.tryParse(json['settled_amount']?.toString() ?? '0') ?? 0,
      pendingAmount: double.tryParse(json['pending_amount']?.toString() ?? '0') ?? 0,
    );
  }
}

class AdminSettlementRecord {
  final int id;
  final int businessId;
  final String businessName;
  final double amount;
  final double remainingAfter;
  final String? notes;
  final String createdAt;

  AdminSettlementRecord({
    required this.id,
    required this.businessId,
    required this.businessName,
    required this.amount,
    required this.remainingAfter,
    this.notes,
    required this.createdAt,
  });

  factory AdminSettlementRecord.fromJson(Map<String, dynamic> json) {
    return AdminSettlementRecord(
      id: json['id'] ?? 0,
      businessId: json['business_id'] ?? 0,
      businessName: json['business_name'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      remainingAfter: double.tryParse(json['remaining_after']?.toString() ?? '0') ?? 0,
      notes: json['notes'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
