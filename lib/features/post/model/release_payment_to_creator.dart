import 'dart:convert';

class ReleasePaymentToCreatorResponse {
  final bool? status;
  final String? message;
  final Data? data;

  ReleasePaymentToCreatorResponse({
    this.status,
    this.message,
    this.data,
  });

  factory ReleasePaymentToCreatorResponse.fromRawJson(String str) => ReleasePaymentToCreatorResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ReleasePaymentToCreatorResponse.fromJson(Map<String, dynamic> json) => ReleasePaymentToCreatorResponse(
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
  final int? postId;
  final List<int>? creatorIds;
  final int? perCreatorAmount;
  final int? businessUserId;

  Data({
    this.postId,
    this.creatorIds,
    this.perCreatorAmount,
    this.businessUserId,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    postId: json["post_id"],
    creatorIds: json["creator_ids"] == null ? [] : List<int>.from(json["creator_ids"]!.map((x) => x)),
    perCreatorAmount: json["per_creator_amount"],
    businessUserId: json["business_user_id"],
  );

  Map<String, dynamic> toJson() => {
    "post_id": postId,
    "creator_ids": creatorIds == null ? [] : List<dynamic>.from(creatorIds!.map((x) => x)),
    "per_creator_amount": perCreatorAmount,
    "business_user_id": businessUserId,
  };
}
