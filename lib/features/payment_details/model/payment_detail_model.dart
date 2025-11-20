import 'dart:convert';

class PaymentDetailModel {
  int? userId;
  String? paymentMobileNumber;
  String? upiId;
  String? bankAccountNumber;
  String? ifsc;
  String? bankName;
  String? branchName;
  String? defaultMethod;

  PaymentDetailModel({
    this.userId,
    this.paymentMobileNumber,
    this.upiId,
    this.bankAccountNumber,
    this.ifsc,
    this.bankName,
    this.branchName,
    this.defaultMethod,
  });

  factory PaymentDetailModel.fromRawJson(String str) =>
      PaymentDetailModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PaymentDetailModel.fromJson(Map<String, dynamic> json) =>
      PaymentDetailModel(
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
