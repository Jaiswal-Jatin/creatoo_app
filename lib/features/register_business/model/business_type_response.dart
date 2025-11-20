import 'dart:convert';

class BusinessTypeResponse {
  bool? status;
  String? message;
  List<BusinessType>? data;

  BusinessTypeResponse({
    this.status,
    this.message,
    this.data,
  });

  factory BusinessTypeResponse.fromRawJson(String str) => BusinessTypeResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusinessTypeResponse.fromJson(Map<String, dynamic> json) => BusinessTypeResponse(
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

  BusinessType({
    this.id,
    this.title,
  });

  factory BusinessType.fromRawJson(String str) => BusinessType.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusinessType.fromJson(Map<String, dynamic> json) => BusinessType(
        id: json["id"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
      };
}
