import 'dart:convert';

class CreateOrderResponseModel {
  bool? status;
  String? message;
  Data? data;

  CreateOrderResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory CreateOrderResponseModel.fromRawJson(String str) => CreateOrderResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CreateOrderResponseModel.fromJson(Map<String, dynamic> json) => CreateOrderResponseModel(
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
  String? orderId;

  Data({
    this.orderId,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        orderId: json["order_id"],
      );

  Map<String, dynamic> toJson() => {
        "order_id": orderId,
      };
}
