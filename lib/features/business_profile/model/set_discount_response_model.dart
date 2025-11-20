import 'dart:convert';

class SetDiscountResponseModel {
  bool? status;
  String? message;
  Data? data;

  SetDiscountResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory SetDiscountResponseModel.fromRawJson(String str) => SetDiscountResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SetDiscountResponseModel.fromJson(Map<String, dynamic> json) => SetDiscountResponseModel(
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
  int? id;

  Data({
    this.id,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
      };
}
