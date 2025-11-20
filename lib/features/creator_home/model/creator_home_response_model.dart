import 'dart:convert';

class CreatorHomeResponse {
  bool? status;
  String? message;
  Data? data;

  CreatorHomeResponse({
    this.status,
    this.message,
    this.data,
  });

  factory CreatorHomeResponse.fromRawJson(String str) => CreatorHomeResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CreatorHomeResponse.fromJson(Map<String, dynamic> json) => CreatorHomeResponse(
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
  int? opportunities;
  int? applied;
  int? onGoingDeals;
  int? successfulDeals;

  Data({
    this.opportunities,
    this.applied,
    this.onGoingDeals,
    this.successfulDeals,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    opportunities: json["opportunities"],
    applied: json["applied"],
    onGoingDeals: json["onGoingDeals"],
    successfulDeals: json["successfulDeals"],
  );

  Map<String, dynamic> toJson() => {
    "opportunities": opportunities,
    "applied": applied,
    "onGoingDeals": onGoingDeals,
    "successfulDeals": successfulDeals,
  };
}
