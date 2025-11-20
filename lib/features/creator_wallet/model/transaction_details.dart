import 'dart:convert';

class TransactionDetails {
  String? paidTo;
  String? receivedFrom;
  DateTime? dateTime;
  String? totalBill;
  String? finalBill;
  double? discountPercentage;
  String? orderId;

  TransactionDetails({
    this.paidTo,
    this.receivedFrom,
    this.dateTime,
    this.discountPercentage,
    this.totalBill,
    this.finalBill,
    this.orderId,
  });

  factory TransactionDetails.fromRawJson(String str) => TransactionDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TransactionDetails.fromJson(Map<String, dynamic> json) => TransactionDetails(
        paidTo: json["paid_to"],
        receivedFrom: json["received_from"],
        discountPercentage: _round(json["discount_percentage"]),
        dateTime: json["date_time"] == null ? null : DateTime.parse(json["date_time"]),
        totalBill: json["total_bill"],
        finalBill: json["final_bill"],
        orderId: json["order_id"],
      );

  Map<String, dynamic> toJson() => {
        "paid_to": paidTo,
        "received_from": receivedFrom,
        "discount_percentage": discountPercentage,
        "date_time": dateTime?.toIso8601String(),
        "total_bill": totalBill,
        "final_bill": finalBill,
        "order_id": orderId,
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

    return parsedValue != null ? double.parse(parsedValue.toStringAsFixed(2)) : null;
  }
}
