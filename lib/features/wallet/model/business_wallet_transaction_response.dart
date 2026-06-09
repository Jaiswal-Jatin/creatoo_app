import 'dart:convert';
import 'dart:developer';

class BusinessWalletTransactionResponse {
  bool? status;
  String? message;
  List<Transaction>? transactions;
  double? lifetimeEarnings;

  BusinessWalletTransactionResponse({
    this.status,
    this.message,
    this.transactions,
    this.lifetimeEarnings,
  });

  factory BusinessWalletTransactionResponse.fromRawJson(String str) =>
      BusinessWalletTransactionResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusinessWalletTransactionResponse.fromJson(
          Map<String, dynamic> json) =>
      BusinessWalletTransactionResponse(
        status: json["status"],
        message: json["message"],
        transactions: json["data"] is List
            ? List<Transaction>.from(
                json["data"].map((x) => Transaction.fromJson(x)))
            : [],
        lifetimeEarnings: json["lifetime_earnings"] != null
            ? double.tryParse(json["lifetime_earnings"].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": transactions == null
            ? []
            : List<dynamic>.from(transactions!.map((x) => x.toJson())),
        "lifetime_earnings": lifetimeEarnings,
      };
}

class Data {
  double? businessWallet;
  List<Transaction>? transactions;

  Data({
    this.businessWallet,
    this.transactions,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        businessWallet: _round(json["business_wallet"]),
        transactions: json["transactions"] is List
            ? List<Transaction>.from(json["transactions"].map((x) {
                if (x is Map<String, dynamic>) {
                  return Transaction.fromJson(x);
                } else {
                  log('Warning: Transaction item is not a Map: $x');
                  return null;
                }
              }).whereType<Transaction>())
            : [],
      );

  Map<String, dynamic> toJson() => {
        "business_wallet": businessWallet,
        "transactions": transactions == null
            ? []
            : List<dynamic>.from(transactions!.map((x) => x.toJson())),
      };

  static double? _round(dynamic value) {
    if (value == null) return null;

    double? parsedValue;

    if (value is int) {
      parsedValue = value.toDouble();
    } else if (value is double) {
      parsedValue = value;
    } else if (value is String) {
      parsedValue = double.tryParse(value);
    }

    return parsedValue != null
        ? double.parse(parsedValue.toStringAsFixed(2))
        : null;
  }
}

class Transaction {
  String? totalBill;
  String? receivedFrom;
  double? discountPercentage;
  double? settlementAmount;
  DateTime? created_at;
  String? referenceNumber;

  Transaction({
    this.totalBill,
    this.receivedFrom,
    this.discountPercentage,
    this.settlementAmount,
    this.created_at,
    this.referenceNumber,
  });

  factory Transaction.fromRawJson(String str) =>
      Transaction.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        totalBill: json["amount"]?.toString(),
        receivedFrom: json["remark"],
        discountPercentage: json["discount_percentage"] != null
            ? double.tryParse(json["discount_percentage"].toString())
            : null,
        settlementAmount: json["settlementAmount"] != null
            ? double.tryParse(json["settlementAmount"].toString())
            : null,
        created_at: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : (json["createdAt"] != null
                ? DateTime.parse(json["createdAt"])
                : null),
        referenceNumber:
            json["order_id"]?.toString() ?? json["display_id"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "total_bill": totalBill,
        "received_from": receivedFrom,
        "discount_percentage": discountPercentage,
        "settlement_amount": settlementAmount,
        "created_at": created_at?.toIso8601String(),
        "order_id": referenceNumber,
      };
}
