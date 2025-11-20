import 'dart:convert';

class BusinessListResponse {
  bool? status;
  String? message;
  List<Business>? data;

  BusinessListResponse({
    this.status,
    this.message,
    this.data,
  });

  factory BusinessListResponse.fromRawJson(String str) => BusinessListResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusinessListResponse.fromJson(Map<String, dynamic> json) => BusinessListResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<Business>.from(json["data"]!.map((x) => Business.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Business {
  int? id;
  String? businessName;

  Business({
    this.id,
    this.businessName,
  });

  factory Business.fromRawJson(String str) => Business.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Business.fromJson(Map<String, dynamic> json) => Business(
    id: json["id"],
    businessName: json["business_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "business_name": businessName,
  };
}
