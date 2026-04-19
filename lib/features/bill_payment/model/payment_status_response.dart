import 'dart:convert';

class PaymentStatusResponse {
  bool? status;
  String? message;
  PaymentData? data;

  PaymentStatusResponse({
    this.status,
    this.message,
    this.data,
  });

  factory PaymentStatusResponse.fromRawJson(String str) =>
      PaymentStatusResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) =>
      PaymentStatusResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : PaymentData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class PaymentData {
  String? businessName;
  int? totalBill;
  int? businessId;
  double? finalBill;
  DateTime? createdAt;
  String? receiptName;
  String? orderId;

  PaymentData({
    this.businessName,
    this.businessId,
    this.totalBill,
    this.finalBill,
    this.createdAt,
    this.receiptName,
    this.orderId,
  });

  factory PaymentData.fromRawJson(String str) =>
      PaymentData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PaymentData.fromJson(Map<String, dynamic> json) => PaymentData(
        businessName: json["business_name"],
        totalBill: json["total_bill"] is int
            ? json["total_bill"]
            : int.tryParse(json["total_bill"]?.toString() ?? "0"),
        businessId: json["business_id"] is int
            ? json["business_id"]
            : int.tryParse(json["business_id"]?.toString() ?? "0"),
        finalBill: json["final_bill"]?.toDouble(),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(
                    json["created_at"].toString().replaceAll(' ', 'T')) ??
                DateTime.tryParse(json["created_at"].toString()),
        receiptName: json["receipt_name"],
        orderId: json["order_id"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "business_name": businessName,
        "total_bill": totalBill,
        "business_id": businessId,
        "final_bill": finalBill,
        "created_at": createdAt?.toIso8601String(),
        "receipt_name": receiptName,
        "order_id": orderId,
      };
}
