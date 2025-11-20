import 'dart:convert';

class ApplyOffersResponseModel {
  bool? status;
  String? message;
  BillSummary? data;

  ApplyOffersResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory ApplyOffersResponseModel.fromRawJson(String str) => ApplyOffersResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ApplyOffersResponseModel.fromJson(Map<String, dynamic> json) => ApplyOffersResponseModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : BillSummary.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class BillSummary {
  double? originalBill;
  bool? isFirstVisit;
  double? discountPercentage;
  String? merchantTransactionId;
  double? discountApplied;
  double? discountedBill;
  double? platformFee;
  double? convenienceFee;
  double? finalBillAmount;
  double? totalPointsForBusiness;
  double? pointsRedeemedHere;
  double? pointsYouWillEarn;

  BillSummary({
    this.originalBill,
    this.isFirstVisit,
    this.discountPercentage,
    this.merchantTransactionId,
    this.discountApplied,
    this.discountedBill,
    this.platformFee,
    this.convenienceFee,
    this.finalBillAmount,
    this.totalPointsForBusiness,
    this.pointsRedeemedHere,
    this.pointsYouWillEarn,
  });

  factory BillSummary.fromJson(Map<String, dynamic> json) => BillSummary(
        originalBill: _round(json["original_bill"]),
        isFirstVisit: json["is_first_visit"],
        discountPercentage: _round(json["discount_percentage"]),
        merchantTransactionId: json["order_id"],
        discountApplied: _round(json["discount_applied"]),
        discountedBill: _round(json["discounted_bill"]),
        platformFee: _round(json["platform_fee"]),
        convenienceFee: _round(json["convenience_fee"]),
        finalBillAmount: _round(json["final_bill_amount"]),
        totalPointsForBusiness: _round(json["total_points_for_business"]),
        pointsRedeemedHere: _round(json["points_redeemed_here"]),
        pointsYouWillEarn: _round(json["points_you_will_earn"]),
      );

  Map<String, dynamic> toJson() => {
        "original_bill": originalBill,
        "is_first_visit": isFirstVisit,
        "discount_percentage": discountPercentage,
        "order_id": merchantTransactionId,
        "discount_applied": discountApplied,
        "discounted_bill": discountedBill,
        "platform_fee": platformFee,
        "convenience_fee": convenienceFee,
        "final_bill_amount": finalBillAmount,
        "total_points_for_business": totalPointsForBusiness,
        "points_redeemed_here": pointsRedeemedHere,
        "points_you_will_earn": pointsYouWillEarn,
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

  static String? _roundString(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      value = value.replaceAll('%', '');
    }
    double? parsedValue = double.tryParse(value.toString());
    if (parsedValue == null) return null;
    String formattedValue = parsedValue % 1 == 0 ? parsedValue.toInt().toString() : parsedValue.toStringAsFixed(2);
    return "$formattedValue%";
  }
}
