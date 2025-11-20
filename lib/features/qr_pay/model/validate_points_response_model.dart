import 'dart:convert';

class ValidatePointsResponseModel {
  bool? status;
  String? message;
  int? flag;
  num? data;

  ValidatePointsResponseModel({
    this.status,
    this.message,
    this.flag,
    this.data,
  });

  factory ValidatePointsResponseModel.fromRawJson(String str) => ValidatePointsResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ValidatePointsResponseModel.fromJson(Map<String, dynamic> json) => ValidatePointsResponseModel(
        status: json["status"],
        message: json["message"],
        flag: json["flag"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "flag": flag,
        "data": data,
      };
}
