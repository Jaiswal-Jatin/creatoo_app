import 'dart:convert';

class FeedbackResponseModel {
  bool? status;
  String? message;
  Data? data;
  int? pointsEarnerd;
  Notification? notification;

  FeedbackResponseModel({
    this.status,
    this.message,
    this.data,
    this.pointsEarnerd,
    this.notification,
  });

  factory FeedbackResponseModel.fromRawJson(String str) => FeedbackResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FeedbackResponseModel.fromJson(Map<String, dynamic> json) => FeedbackResponseModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        pointsEarnerd: json["points_earnerd"],
        notification: json["notification"] == null ? null : Notification.fromJson(json["notification"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
        "points_earnerd": pointsEarnerd,
        "notification": notification?.toJson(),
      };
}

class Data {
  int? userId;
  int? businessId;
  int? experience;
  int? expectation;
  int? recommend;
  int? fairMoney;
  int? interaction;
  String? reviewText;
  String? orderId;
  DateTime? updatedAt;
  DateTime? createdAt;
  int? id;

  Data({
    this.userId,
    this.businessId,
    this.experience,
    this.expectation,
    this.recommend,
    this.fairMoney,
    this.interaction,
    this.reviewText,
    this.orderId,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        userId: json["user_id"],
        businessId: json["business_id"],
        experience: json["experience"],
        expectation: json["expectation"],
        recommend: json["recommend"],
        fairMoney: json["fair_money"],
        interaction: json["interaction"],
        reviewText: json["review_text"],
        orderId: json["order_id"],
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "business_id": businessId,
        "experience": experience,
        "expectation": expectation,
        "recommend": recommend,
        "fair_money": fairMoney,
        "interaction": interaction,
        "review_text": reviewText,
        "order_id": orderId,
        "updated_at": updatedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "id": id,
      };
}

class Notification {
  String? title;
  String? description;

  Notification({
    this.title,
    this.description,
  });

  factory Notification.fromRawJson(String str) => Notification.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        title: json["title"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
      };
}
