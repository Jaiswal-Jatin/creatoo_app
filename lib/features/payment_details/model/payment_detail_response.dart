import 'dart:convert';

class PaymentDetailResponse {
  bool? status;
  String? message;
  PaymentDetail? data;

  PaymentDetailResponse({
    this.status,
    this.message,
    this.data,
  });

  factory PaymentDetailResponse.fromRawJson(String str) =>
      PaymentDetailResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PaymentDetailResponse.fromJson(Map<String, dynamic> json) =>
      PaymentDetailResponse(
        status: json["status"],
        message: json["message"],
        data:
            json["data"] == null ? null : PaymentDetail.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class PaymentDetail {
  int? userId;
  String? paymentMobileNumber;
  String? upiId;
  String? bankAccountNumber;
  String? ifsc;
  String? bankName;
  String? branchName;
  String? defaultMethod;

  PaymentDetail({
    this.userId,
    this.paymentMobileNumber,
    this.upiId,
    this.bankAccountNumber,
    this.ifsc,
    this.bankName,
    this.branchName,
    this.defaultMethod,
  });

  factory PaymentDetail.fromRawJson(String str) =>
      PaymentDetail.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PaymentDetail.fromJson(Map<String, dynamic> json) => PaymentDetail(
        userId: json["user_id"],
        paymentMobileNumber: json["payment_mobile_number"],
        upiId: json["upi_id"],
        bankAccountNumber: json["bank_account_number"],
        ifsc: json["IFSC"],
        bankName: json["bank_name"],
        branchName: json["branch_name"],
        defaultMethod: json["default_method"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "payment_mobile_number": paymentMobileNumber,
        "upi_id": upiId,
        "bank_account_number": bankAccountNumber,
        "IFSC": ifsc,
        "bank_name": bankName,
        "branch_name": branchName,
        "default_method": defaultMethod,
      };
}
