import 'dart:convert';

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is bool) return value ? 1 : 0;
  if (value is String) return int.tryParse(value);
  return null;
}

class OpportunityResponse {
  bool? status;
  String? message;
  List<Opportunity>? data;

  OpportunityResponse({
    this.status,
    this.message,
    this.data,
  });

  factory OpportunityResponse.fromRawJson(String str) => OpportunityResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OpportunityResponse.fromJson(Map<String, dynamic> json) => OpportunityResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<Opportunity>.from(json["data"]!.map((x) => Opportunity.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Opportunity {
  int? id;
  int? userId;
  String? name;
  String? description;
  int? budget;
  int? duration;
  String? deliverable;
  int? followersRequired;
  int? workMode;
  int? creatorRequired;
  int? perCreatorAmount;
  dynamic transactionD;
  String? totalAmount;
  String? status;
  String? isReported;
  int? isActive;
  int? counts;
  String? postStatus;
  String? paymentStatus;
  dynamic paymentStatusResponse;
  dynamic orderId;
  DateTime? createdAt;
  dynamic postExpiryDate;
  DateTime? updatedAt;
  int flagReported;

  Opportunity({
    this.id,
    this.userId,
    this.name,
    this.description,
    this.budget,
    this.duration,
    this.deliverable,
    this.followersRequired,
    this.workMode,
    this.creatorRequired,
    this.perCreatorAmount,
    this.transactionD,
    this.totalAmount,
    this.status,
    this.isReported,
    this.isActive,
    this.counts,
    this.postStatus,
    this.paymentStatus,
    this.paymentStatusResponse,
    this.orderId,
    this.createdAt,
    this.postExpiryDate,
    this.updatedAt,
    this.flagReported = 0,
  });

  factory Opportunity.fromRawJson(String str) => Opportunity.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Opportunity.fromJson(Map<String, dynamic> json) => Opportunity(
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
    isActive: _toInt(json["is_active"]),
    counts: json["counts"],
    postStatus: json["post_status"],
    paymentStatus: json["payment_status"],
    paymentStatusResponse: json["payment_status_response"],
    orderId: json["order_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    postExpiryDate: json["post_expiry_date"],
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    flagReported:json["flag"] ?? 0,
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
    "payment_status": paymentStatus,
    "payment_status_response": paymentStatusResponse,
    "order_id": orderId,
    "created_at": createdAt?.toIso8601String(),
    "post_expiry_date": postExpiryDate,
    "updated_at": updatedAt?.toIso8601String(),
    "flag": flagReported,
  };
}
