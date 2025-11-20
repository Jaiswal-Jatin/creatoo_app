import 'dart:convert';

class CreatorWalletTransactionResponse {
  bool? status;
  String? message;
  Data? data;

  CreatorWalletTransactionResponse({
    this.status,
    this.message,
    this.data,
  });

  factory CreatorWalletTransactionResponse.fromRawJson(String str) => CreatorWalletTransactionResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CreatorWalletTransactionResponse.fromJson(Map<String, dynamic> json) => CreatorWalletTransactionResponse(
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
  int? walletAmount;
  List<Transaction>? transactions;

  Data({
    this.walletAmount,
    this.transactions,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        walletAmount: json["wallet_amount"],
        transactions: json["transactions"] == null ? [] : List<Transaction>.from(json["transactions"]!.map((x) => Transaction.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "wallet_amount": walletAmount,
        "transactions": transactions == null ? [] : List<dynamic>.from(transactions!.map((x) => x.toJson())),
      };
}

class Transaction {
  String? paidTo;
  DateTime? dateTime;
  String? totalBill;
  String? finalBill;
  String? referenceNumber;

  Transaction({
    this.paidTo,
    this.dateTime,
    this.totalBill,
    this.finalBill,
    this.referenceNumber,
  });

  factory Transaction.fromRawJson(String str) => Transaction.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        paidTo: json["paid_to"],
        dateTime: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        totalBill: json["bill_amount"],
        finalBill: json["final_bill_amount"],
        referenceNumber: json["order_id"],
      );

  Map<String, dynamic> toJson() => {
        "paid_to": paidTo,
        "created_at": dateTime?.toIso8601String(),
        "bill_amount": totalBill,
        "final_bill_amount": finalBill,
        "order_id": referenceNumber,
      };
}
