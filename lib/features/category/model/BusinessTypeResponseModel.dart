import 'dart:convert';

class BusinessTypeResponseModel {
  bool? status;
  String? message;
  List<BusinessType>? data;

  BusinessTypeResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory BusinessTypeResponseModel.fromRawJson(String str) => BusinessTypeResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusinessTypeResponseModel.fromJson(Map<String, dynamic> json) => BusinessTypeResponseModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<BusinessType>.from(json["data"]!.map((x) => BusinessType.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class BusinessType {
  int? id;
  String? title;
  String? image;

  BusinessType({
    this.id,
    this.title,
    this.image,
  });

  factory BusinessType.fromRawJson(String str) => BusinessType.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusinessType.fromJson(Map<String, dynamic> json) => BusinessType(
        id: json["id"],
        title: json["title"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "image": image,
      };
}
