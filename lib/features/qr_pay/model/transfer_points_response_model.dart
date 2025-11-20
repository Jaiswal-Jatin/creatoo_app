import 'dart:convert';

class TransferPointsResponseModel {
  bool? status;
  String? message;
  Data? data;

  TransferPointsResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory TransferPointsResponseModel.fromRawJson(String str) => TransferPointsResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TransferPointsResponseModel.fromJson(Map<String, dynamic> json) => TransferPointsResponseModel(
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
  String? transactionId;
  num? transferredPoints;

  Data({
    this.transactionId,
    this.transferredPoints,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        transactionId: json["transaction_id"],
        transferredPoints: json["transferred_points"],
      );

  Map<String, dynamic> toJson() => {
        "transaction_id": transactionId,
        "transferred_points": transferredPoints,
      };
}
