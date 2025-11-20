import 'dart:convert';

class ViewMyPostResponse {
  bool status;
  String message;
  List<Datum> data;

  ViewMyPostResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ViewMyPostResponse.fromRawJson(String str) => ViewMyPostResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ViewMyPostResponse.fromJson(Map<String, dynamic> json) => ViewMyPostResponse(
    status: json["status"],
    message: json["message"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  int id;
  int userId;
  String name;
  String description;
  int budget;
  int duration;
  String deliverable;
  int followersRequired;
  int workMode;
  int creatorRequired;
  int perCreatorAmount;
  dynamic transactionD;
  String totalAmount;
  String status;
  String isReported;
  int isActive;
  int counts;
  String postStatus;
  DateTime createdAt;
  dynamic postExpiryDate;
  DateTime updatedAt;
  int? postInterestCount;

  Datum({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.budget,
    required this.duration,
    required this.deliverable,
    required this.followersRequired,
    required this.workMode,
    required this.creatorRequired,
    required this.perCreatorAmount,
    required this.transactionD,
    required this.totalAmount,
    required this.status,
    required this.isReported,
    required this.isActive,
    required this.counts,
    required this.postStatus,
    required this.createdAt,
    required this.postExpiryDate,
    required this.updatedAt,
    required this.postInterestCount,
  });

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    userId: json["user_id"],
    name: json["name"],
    description: json["description"],
    budget: json["budget"],
    duration: json["duration"],
    deliverable: json["deliverable"],
    followersRequired: json["followers_required"],
    workMode: json["work_mode"],
    creatorRequired: json["creator_required"],
    perCreatorAmount: json["per_creator_amount"],
    transactionD: json["transaction_d"],
    totalAmount: json["total_amount"],
    status: json["status"],
    isReported: json["is_reported"],
    isActive: json["is_active"],
    counts: json["counts"],
    postStatus: json["post_status"],
    createdAt: DateTime.parse(json["created_at"]),
    postExpiryDate: json["post_expiry_date"],
    updatedAt: DateTime.parse(json["updated_at"]),
    postInterestCount: json["post_interest_count"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "name": name,
    "description": description,
    "budget": budget,
    "duration": duration,
    "deliverable": deliverable,
    "followers_required": followersRequired,
    "work_mode": workMode,
    "creator_required": creatorRequired,
    "per_creator_amount": perCreatorAmount,
    "transaction_d": transactionD,
    "total_amount": totalAmount,
    "status": status,
    "is_reported": isReported,
    "is_active": isActive,
    "counts": counts,
    "post_status": postStatus,
    "created_at": createdAt.toIso8601String(),
    "post_expiry_date": postExpiryDate,
    "updated_at": updatedAt.toIso8601String(),
    "post_interest_count": postInterestCount,
  };
}
