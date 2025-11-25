import 'dart:convert';

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is bool) return value ? 1 : 0;
  if (value is String) return int.tryParse(value);
  return null;
}

class PaymentResponse {
  bool? status;
  String? message;
  Data? data;

  PaymentResponse({
    this.status,
    this.message,
    this.data,
  });

  factory PaymentResponse.fromRawJson(String str) => PaymentResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PaymentResponse.fromJson(Map<String, dynamic> json) => PaymentResponse(
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
  String? paymentStatus;
  int? receivedAmount;
  String? paymentStatusResponse;
  String? totalAmount;
  String? status;
  String? isReported;
  int? isActive;
  int? counts;
  DateTime? createdAt;
  dynamic postExpiryDate;
  DateTime? updatedAt;

  Data({
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
    this.paymentStatus,
    this.receivedAmount,
    this.paymentStatusResponse,
    this.totalAmount,
    this.status,
    this.isReported,
    this.isActive,
    this.counts,
    this.createdAt,
    this.postExpiryDate,
    this.updatedAt,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
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
    paymentStatus: json["payment_status"],
    receivedAmount: json["received_amount"],
    paymentStatusResponse: json["payment_status_response"],
    totalAmount: json["total_amount"],
    status: json["status"],
    isReported: json["is_reported"],
    isActive: _toInt(json["is_active"]),
    counts: json["counts"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    postExpiryDate: json["post_expiry_date"],
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
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
    "payment_status": paymentStatus,
    "received_amount": receivedAmount,
    "payment_status_response": paymentStatusResponse,
    "total_amount": totalAmount,
    "status": status,
    "is_reported": isReported,
    "is_active": isActive,
    "counts": counts,
    "created_at": createdAt?.toIso8601String(),
    "post_expiry_date": postExpiryDate,
    "updated_at": updatedAt?.toIso8601String(),
  };
}
