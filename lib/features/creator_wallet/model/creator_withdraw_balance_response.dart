import 'dart:convert';

class CreatorWithdrawBalanceResponse {
  bool? status;
  String? message;
  Data? data;

  CreatorWithdrawBalanceResponse({
    this.status,
    this.message,
    this.data,
  });

  factory CreatorWithdrawBalanceResponse.fromRawJson(String str) => CreatorWithdrawBalanceResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CreatorWithdrawBalanceResponse.fromJson(Map<String, dynamic> json) => CreatorWithdrawBalanceResponse(
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
  int? userId;
  int? amount;
  dynamic creditDebit;
  String? remark;
  String? isWithdrawRequest;
  DateTime? updatedAt;
  DateTime? createdAt;
  int? id;

  Data({
    this.userId,
    this.amount,
    this.creditDebit,
    this.remark,
    this.isWithdrawRequest,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    userId: json["user_id"],
    amount: json["amount"],
    creditDebit: json["credit_debit"],
    remark: json["remark"],
    isWithdrawRequest: json["is_withdraw_request"],
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "amount": amount,
    "credit_debit": creditDebit,
    "remark": remark,
    "is_withdraw_request": isWithdrawRequest,
    "updated_at": updatedAt?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "id": id,
  };
}
