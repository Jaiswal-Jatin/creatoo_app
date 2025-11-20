import 'dart:convert';

class SkipFeedbackResponseModel {
  bool? status;
  String? message;
  Data? data;

  SkipFeedbackResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory SkipFeedbackResponseModel.fromRawJson(String str) => SkipFeedbackResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SkipFeedbackResponseModel.fromJson(Map<String, dynamic> json) => SkipFeedbackResponseModel(
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
  int? userId;
  String? orderId;
  String? notificationText;
  int? isRedeemed;
  DateTime? updatedAt;
  DateTime? createdAt;
  int? id;

  Data({
    this.userId,
    this.orderId,
    this.notificationText,
    this.isRedeemed,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        userId: json["user_id"],
        orderId: json["order_id"],
        notificationText: json["notification_text"],
        isRedeemed: json["is_redeemed"],
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "order_id": orderId,
        "notification_text": notificationText,
        "is_redeemed": isRedeemed,
        "updated_at": updatedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "id": id,
      };
}
