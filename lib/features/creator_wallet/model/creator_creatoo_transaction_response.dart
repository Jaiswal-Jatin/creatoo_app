import 'dart:convert';

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  final str = value.toString().trim();
  if (str.isEmpty) return null;
  // Try ISO format first ("2026-05-25T22:22:52" or with "Z")
  try {
    return DateTime.parse(str);
  } catch (_) {}
  // Try MySQL format ("2026-05-25 22:22:52")
  try {
    return DateTime.parse(str.replaceFirst(' ', 'T'));
  } catch (_) {}
  return null;
}

class CreatorCreatooPointTransactionResponse {
  bool? status;
  String? message;
  Data? data;

  CreatorCreatooPointTransactionResponse({
    this.status,
    this.message,
    this.data,
  });

  factory CreatorCreatooPointTransactionResponse.fromRawJson(String str) =>
      CreatorCreatooPointTransactionResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CreatorCreatooPointTransactionResponse.fromJson(Map<String, dynamic> json) => CreatorCreatooPointTransactionResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  int? creatooPoints;
  List<BusinessTransaction>? businessTransactions;

  Data({
    this.creatooPoints,
    this.businessTransactions,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        creatooPoints: json["creatoo_points"],
        businessTransactions: json["businessTransactions"] == null
            ? []
            : List<BusinessTransaction>.from(json["businessTransactions"]!.map((x) => BusinessTransaction.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "creatoo_points": creatooPoints,
        "businessTransactions": businessTransactions == null ? [] : List<dynamic>.from(businessTransactions!.map((x) => x.toJson())),
      };
}

class BusinessTransaction {
  int? businessId;
  String? businessName;
  int? totalPoints;
  List<Transaction>? transactions;

  BusinessTransaction({
    this.businessId,
    this.businessName,
    this.totalPoints,
    this.transactions,
  });

  factory BusinessTransaction.fromRawJson(String str) => BusinessTransaction.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusinessTransaction.fromJson(Map<String, dynamic> json) => BusinessTransaction(
        businessId: json["business_id"],
        businessName: json["business_name"],
        totalPoints: json["total_points"],
        transactions: json["transactions"] == null ? [] : List<Transaction>.from(json["transactions"]!.map((x) => Transaction.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "business_id": businessId,
        "business_name": businessName,
        "total_points": totalPoints,
        "transactions": transactions == null ? [] : List<dynamic>.from(transactions!.map((x) => x.toJson())),
      };
}

class Transaction {
  int? id;
  int? userId;
  int? businessId;
  String? orderId;
  int? points;
  DateTime? expiryDate;
  String? creditDebitRemainingStatus;
  String? businessName;
  String? totalBill;
  String? finalBill;
  String? receiptName;
  int? remainingPoints;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isExpired;

  Transaction({
    this.id,
    this.userId,
    this.businessId,
    this.orderId,
    this.points,
    this.expiryDate,
    this.creditDebitRemainingStatus,
    this.businessName,
    this.totalBill,
    this.finalBill,
    this.receiptName,
    this.remainingPoints,
    this.createdAt,
    this.updatedAt,
    this.isExpired,
  });

  factory Transaction.fromRawJson(String str) => Transaction.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json["id"],
        userId: json["user_id"],
        businessId: json["business_id"],
        orderId: json["order_id"],
        points: json["points"],
        expiryDate: _parseDate(json["expiry_date"]),
        creditDebitRemainingStatus: json["credit_debit_remaining_status"],
        businessName: json["business_name"],
        totalBill: json["total_bill"],
        finalBill: json["final_bill"],
        receiptName: json["receipt_name"],
        remainingPoints: json["remaining_points"],
        createdAt: _parseDate(json["created_at"]) ?? _parseDate(json["createdAt"]),
        updatedAt: _parseDate(json["updated_at"]) ?? _parseDate(json["updatedAt"]),
        isExpired: json["is_expired"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "business_id": businessId,
        "order_id": orderId,
        "points": points,
        "expiry_date": expiryDate?.toIso8601String(),
        "credit_debit_remaining_status": creditDebitRemainingStatus,
        "business_name": businessName,
        "total_bill": totalBill,
        "final_bill": finalBill,
        "receipt_name": receiptName,
        "remaining_points": remainingPoints,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "is_expired": isExpired,
      };
}
