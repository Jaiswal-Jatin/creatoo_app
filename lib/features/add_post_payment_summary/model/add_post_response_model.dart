import 'dart:convert';

import 'package:creatoo/features/add_post_payment_summary/model/setting_response_model.dart';

class AddPostResponseModel {
  bool? status;
  String? message;
  AddPostResponse? data;

  AddPostResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory AddPostResponseModel.fromRawJson(String str) => AddPostResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AddPostResponseModel.fromJson(Map<String, dynamic> json) => AddPostResponseModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : AddPostResponse.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class AddPostResponse {
  int? newWalletAmount;
  Post? post;
  Setting? setting;

  AddPostResponse({
    this.newWalletAmount,
    this.post,
    this.setting,
  });

  factory AddPostResponse.fromRawJson(String str) => AddPostResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AddPostResponse.fromJson(Map<String, dynamic> json) => AddPostResponse(
    newWalletAmount: json["new_wallet_amount"],
    post: json["post"] == null ? null : Post.fromJson(json["post"]),
    setting: json["setting"] == null ? null : Setting.fromJson(json["setting"]),
  );

  Map<String, dynamic> toJson() => {
    "new_wallet_amount": newWalletAmount,
    "post": post?.toJson(),
    "setting": setting?.toJson(),
  };
}

class Post {
  String? name;
  String? description;
  int? budget;
  double? totalAmount;
  int? duration;
  String? deliverable;
  int? followersRequired;
  int? workMode;
  int? creatorRequired;
  int? userId;
  int? perCreatorAmount;
  String? postExpiryDate;
  DateTime? updatedAt;
  DateTime? createdAt;
  int? id;
  String? orderId;

  Post({
    this.name,
    this.description,
    this.budget,
    this.totalAmount,
    this.duration,
    this.deliverable,
    this.followersRequired,
    this.workMode,
    this.creatorRequired,
    this.userId,
    this.perCreatorAmount,
    this.postExpiryDate,
    this.updatedAt,
    this.createdAt,
    this.id,
    this.orderId,
  });

  factory Post.fromRawJson(String str) => Post.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    name: json["name"],
    description: json["description"],
    budget: json["budget"],
    totalAmount: double.parse(json["total_amount"].toString()),
    duration: json["duration"],
    deliverable: json["deliverable"],
    followersRequired: json["followers_required"],
    workMode: json["work_mode"],
    creatorRequired: json["creator_required"],
    userId: json["user_id"],
    perCreatorAmount: json["per_creator_amount"],
    postExpiryDate: json["post_expiry_date"],
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    id: json["id"],
    orderId: json["order_id"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "description": description,
    "budget": budget,
    "total_amount": totalAmount,
    "duration": duration,
    "deliverable": deliverable,
    "followers_required": followersRequired,
    "work_mode": workMode,
    "creator_required": creatorRequired,
    "user_id": userId,
    "per_creator_amount": perCreatorAmount,
    "post_expiry_date": postExpiryDate,
    "updated_at": updatedAt?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "id": id,
    "order_id": orderId,
  };
}
