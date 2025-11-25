import 'dart:convert';

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is bool) return value ? 1 : 0;
  if (value is String) return int.tryParse(value);
  return null;
}

class PostDetailResponse {
  bool? status;
  String? message;
  Data? data;

  PostDetailResponse({
    this.status,
    this.message,
    this.data,
  });

  factory PostDetailResponse.fromRawJson(String str) =>
      PostDetailResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PostDetailResponse.fromJson(Map<String, dynamic> json) =>
      PostDetailResponse(
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
  String? transactionD;
  String? totalAmount;
  String? status;
  String? isReported;
  int? isActive;
  String? orderId;
  int? counts;
  String? postStatus;
  String? paymentStatus;
  String? paymentStatusResponse;
  DateTime? createdAt;
  String? postExpiryDate;
  DateTime? updatedAt;
  int? applicationUserInterestStatus;
  Business? business;

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
    this.totalAmount,
    this.status,
    this.isReported,
    this.isActive,
    this.orderId,
    this.counts,
    this.postStatus,
    this.paymentStatus,
    this.paymentStatusResponse,
    this.createdAt,
    this.postExpiryDate,
    this.updatedAt,
    this.applicationUserInterestStatus,
    this.business,
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
        totalAmount: json["total_amount"],
        status: json["status"],
        isReported: json["is_reported"],
        isActive: _toInt(json["is_active"]),
        orderId: json["order_id"],
        counts: json["counts"],
        postStatus: json["post_status"],
        paymentStatus: json["payment_status"],
        paymentStatusResponse: json["payment_status_response"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        postExpiryDate: json["post_expiry_date"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        applicationUserInterestStatus: json["application_user_interest_status"],
        business: json["business"] == null
            ? null
            : Business.fromJson(json["business"]),
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
        "order_id": orderId,
        "counts": counts,
        "post_status": postStatus,
        "payment_status": paymentStatus,
        "payment_status_response": paymentStatusResponse,
        "created_at": createdAt?.toIso8601String(),
        "post_expiry_date": postExpiryDate,
        "updated_at": updatedAt?.toIso8601String(),
        "application_user_interest_status": applicationUserInterestStatus,
        "business": business?.toJson(),
      };
}

class Business {
  int? id;
  String? businessName;
  String? businessFullname;
  String? businessEmail;
  String? businessAddress;
  String? businessMobile;

  Business({
    this.id,
    this.businessName,
    this.businessFullname,
    this.businessEmail,
    this.businessAddress,
    this.businessMobile,
  });

  factory Business.fromRawJson(String str) =>
      Business.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Business.fromJson(Map<String, dynamic> json) => Business(
        id: json["id"],
        businessName: json["business_name"],
        businessFullname: json["business_fullname"],
        businessEmail: json["business_email"],
        businessAddress: json["business_address"],
        businessMobile: json["business_mobile"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "business_name": businessName,
        "business_fullname": businessFullname,
        "business_email": businessEmail,
        "business_address": businessAddress,
        "business_mobile": businessMobile,
      };
}
