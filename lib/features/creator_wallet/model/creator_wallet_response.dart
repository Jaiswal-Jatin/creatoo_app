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
  num? walletAmount;
  List<Transaction>? transactions;

  Data({
    this.walletAmount,
    this.transactions,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        walletAmount: (json["wallet_amount"] as num?),
        transactions: json["transactions"] == null ? [] : List<Transaction>.from(json["transactions"]!.map((x) => Transaction.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "wallet_amount": walletAmount,
        "transactions": transactions == null ? [] : List<dynamic>.from(transactions!.map((x) => x.toJson())),
      };
}

class Transaction {
  String? paidTo;
  String? businessImage;
  DateTime? dateTime;
  String? totalBill;
  String? finalBill;
  double? discountPercentage;
  String? referenceNumber;

  Transaction({
    this.paidTo,
    this.businessImage,
    this.dateTime,
    this.totalBill,
    this.finalBill,
    this.discountPercentage,
    this.referenceNumber,
  });

  factory Transaction.fromRawJson(String str) => Transaction.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        paidTo: json["paid_to"],
        businessImage: json["business_image"],
        dateTime: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        totalBill: json["bill_amount"]?.toString(),
        finalBill: json["final_bill_amount"]?.toString(),
        discountPercentage: json["discount_percentage"] != null
            ? double.tryParse(json["discount_percentage"].toString())
            : null,
        referenceNumber: json["order_id"],
      );

  Map<String, dynamic> toJson() => {
        "paid_to": paidTo,
        "business_image": businessImage,
        "created_at": dateTime?.toIso8601String(),
        "bill_amount": totalBill,
        "final_bill_amount": finalBill,
        "discount_percentage": discountPercentage,
        "order_id": referenceNumber,
      };
}
