import 'dart:convert';

class CreatooPointsResponse {
  bool? status;
  String? message;
  Data? data;

  CreatooPointsResponse({
    this.status,
    this.message,
    this.data,
  });

  factory CreatooPointsResponse.fromRawJson(String str) => CreatooPointsResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CreatooPointsResponse.fromJson(Map<String, dynamic> json) => CreatooPointsResponse(
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
  int? creatorId;
  String? image;
  int? businessId;
  DateTime? updatedAt;
  DateTime? createdAt;
  int? id;

  Data({
    this.creatorId,
    this.image,
    this.businessId,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    creatorId: json["creator_id"],
    image: json["image"],
    businessId: json["business_id"],
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "creator_id": creatorId,
    "image": image,
    "business_id": businessId,
    "updated_at": updatedAt?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "id": id,
  };
}
