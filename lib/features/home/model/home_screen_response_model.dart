import 'dart:convert';
import '../../../utils/helper/type_converter.dart';

// Helper function to convert bool/int to int
int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is bool) return value ? 1 : 0;
  if (value is String) return int.tryParse(value);
  return null;
}

class HomeDataResponse {
  bool? status;
  Data? data;
  String? message;

  HomeDataResponse({
    this.status,
    this.data,
    this.message,
  });

  factory HomeDataResponse.fromRawJson(String str) => HomeDataResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory HomeDataResponse.fromJson(Map<String, dynamic> json) => HomeDataResponse(
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
  List<Baner>? banners;
  List<Business>? topBusiness;
  List<Reviewer>? topReviewers;
  List<Creator>? newCreator;
  List<Business>? newBusiness;
  PaymentStatus? paymentStatus;
  RoleSpecificData? roleSpecificData;
  IsPendingReviewFlag? isPendingReviewFlag;
  String? orderId;

  Data({
    this.banners,
    this.topBusiness,
    this.topReviewers,
    this.newCreator,
    this.newBusiness,
    this.paymentStatus,
    this.roleSpecificData,
    this.isPendingReviewFlag,
    this.orderId,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        banners: json["banners"] == null ? [] : List<Baner>.from(json["banners"].map((x) => Baner.fromJson(x))),
        topBusiness: json["topBusiness"] == null ? [] : List<Business>.from(json["topBusiness"].map((x) => Business.fromJson(x))),
        newCreator: json["newCreator"] == null ? [] : List<Creator>.from(json["newCreator"].map((x) => Creator.fromJson(x))),
        newBusiness: json["newBusiness"] == null ? [] : List<Business>.from(json["newBusiness"].map((x) => Business.fromJson(x))),
        topReviewers:
            json["top_reviews"] == null ? [] : List<Reviewer>.from(json["top_reviews"].map((x) => Reviewer.fromJson(x))), // Added this
        paymentStatus: json["paymentStatus"] == null ? null : PaymentStatus.fromJson(json["paymentStatus"]),
        roleSpecificData: json["role_specific_data"] == null ? null : RoleSpecificData.fromJson(json["role_specific_data"]),
        isPendingReviewFlag: json["is_pending_review_flag"] == null ? null : IsPendingReviewFlag.fromJson(json["is_pending_review_flag"]),
        orderId: json["order_id"],
      );

  Map<String, dynamic> toJson() => {
        "banners": banners == null ? [] : List<dynamic>.from(banners!.map((x) => x.toJson())),
        "topBusiness": topBusiness == null ? [] : List<dynamic>.from(topBusiness!.map((x) => x.toJson())),
        "newCreator": newCreator == null ? [] : List<dynamic>.from(newCreator!.map((x) => x.toJson())),
        "newBusiness": newBusiness == null ? [] : List<dynamic>.from(newBusiness!.map((x) => x.toJson())),
        "top_reviews": topReviewers == null ? [] : List<dynamic>.from(topReviewers!.map((x) => x.toJson())), // Added this
        "paymentStatus": paymentStatus?.toJson(),
        "role_specific_data": roleSpecificData?.toJson(),
        "is_pending_review_flag": isPendingReviewFlag?.toJson(),
        "order_id": orderId,
      };
}

class Reviewer {
  int? id;
  String? name;
  String? userImage;
  int? totalReviews;

  Reviewer({
    this.id,
    this.name,
    this.userImage,
    this.totalReviews,
  });

  factory Reviewer.fromJson(Map<String, dynamic> json) => Reviewer(
        id: json["id"],
        name: json["name"],
        userImage: json["user_image"],
        totalReviews: json["total_reviews"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "user_image": userImage,
        "total_reviews": totalReviews,
      };
}

class PaymentStatus {
  String? entity;
  int? count;
  List<dynamic>? items;

  PaymentStatus({
    this.entity,
    this.count,
    this.items,
  });

  factory PaymentStatus.fromRawJson(String str) => PaymentStatus.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PaymentStatus.fromJson(Map<String, dynamic> json) => PaymentStatus(
        entity: json["entity"],
        count: json["count"],
        items: json["items"] == null ? [] : List<dynamic>.from(json["items"]),
      );

  Map<String, dynamic> toJson() => {
        "entity": entity,
        "count": count,
        "items": items == null ? [] : List<dynamic>.from(items!),
      };
}

class RoleSpecificData {
  String? qrCode;
  num? todayWalletPoints;
  num? userCreatooPoints;
  int? profileCompletionStatus;

  RoleSpecificData({
    this.qrCode,
    this.todayWalletPoints,
    this.userCreatooPoints,
    this.profileCompletionStatus,
  });

  factory RoleSpecificData.fromRawJson(String str) => RoleSpecificData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RoleSpecificData.fromJson(Map<String, dynamic> json) => RoleSpecificData(
        qrCode: json["qr_code"],
        todayWalletPoints: _round(json["today_wallet_points"]),
        userCreatooPoints: json["user_creatoo_points"],
        profileCompletionStatus: json["profile_completion_status"],
      );

  Map<String, dynamic> toJson() => {
        "qr_code": qrCode,
        "today_wallet_points": todayWalletPoints,
        "user_creatoo_points": userCreatooPoints,
        "profile_completion_status": profileCompletionStatus,
      };

  static double? _round(dynamic value) {
    if (value == null) return null;

    double? parsedValue;

    if (value is int) {
      parsedValue = value.toDouble();
    } else if (value is double) {
      parsedValue = value;
    } else if (value is String) {
      parsedValue = double.tryParse(value);
    }

    return parsedValue != null ? double.parse(parsedValue.toStringAsFixed(2)) : null;
  }
}

class Baner {
  int? id;
  String? image;
  String? link;
  int? isActive;

  Baner({
    this.id,
    this.image,
    this.link,
    this.isActive,
  });

  factory Baner.fromRawJson(String str) => Baner.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Baner.fromJson(Map<String, dynamic> json) => Baner(
        id: json["id"],
        image: json["image"],
        link: json["link"],
        isActive: _toInt(json["is_active"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "link": link,
        "is_active": isActive,
      };
}

class Business {
  int? id;
  String? businessFullName;
  String? businessName;
  String? businessEmail;
  String? businessMobile;
  String? businessArea;
  String? businessSiteUrl;
  String? businessImage;
  int? isActive;
  int? isTop;
  int? roleId;

  Business({
    this.id,
    this.businessFullName,
    this.businessName,
    this.businessEmail,
    this.businessMobile,
    this.businessArea,
    this.businessSiteUrl,
    this.businessImage,
    this.isActive,
    this.isTop,
    this.roleId,
  });

  factory Business.fromRawJson(String str) => Business.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Business.fromJson(Map<String, dynamic> json) => Business(
        id: json["id"],
        businessFullName: json["business_fullname"],
        businessName: json["business_name"],
        businessEmail: json["business_email"],
        businessMobile: json["business_mobile"],
        businessArea: json["business_area"],
        businessSiteUrl: json["business_site_url"],
        businessImage: json["business_image"],
        isActive: _toInt(json["is_active"]),
        isTop: _toInt(json["is_top"]),
        roleId: json["role_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "business_fullname": businessFullName,
        "business_name": businessName,
        "business_email": businessEmail,
        "business_mobile": businessMobile,
        "business_area": businessArea,
        "business_site_url": businessSiteUrl,
        "business_image": businessImage,
        "is_active": isActive,
        "is_top": isTop,
        "role_id": roleId,
      };
}

class Creator {
  int? id;
  String? name;
  String? email;
  String? mobile;
  String? instagramLink;
  String? instagramUsername;
  String? userImage;
  int? isActive;
  int? isTop;
  int? roleId;
  String? address;

  Creator({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.instagramLink,
    this.instagramUsername,
    this.userImage,
    this.isActive,
    this.isTop,
    this.roleId,
    this.address,
  });

  factory Creator.fromRawJson(String str) => Creator.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Creator.fromJson(Map<String, dynamic> json) => Creator(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        mobile: json["mobile"],
        instagramLink: json["instagram_link"],
        instagramUsername: json["instagram_username"],
        userImage: json["user_image"],
        isActive: _toInt(json["is_active"]),
        isTop: _toInt(json["is_top"]),
        roleId: json["role_id"],
        address: json["address"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "mobile": mobile,
        "instagram_link": instagramLink,
        "instagram_username": instagramUsername,
        "user_image": userImage,
        "is_active": isActive,
        "is_top": isTop,
        "role_id": roleId,
        "address": address,
      };
}

class IsPendingReviewFlag {
  String? businessName;
  int? businessId;
  String? orderId;

  IsPendingReviewFlag({
    this.businessName,
    this.businessId,
    this.orderId,
  });

  factory IsPendingReviewFlag.fromRawJson(String str) => IsPendingReviewFlag.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory IsPendingReviewFlag.fromJson(Map<String, dynamic> json) => IsPendingReviewFlag(
        businessName: json["business_name"],
        businessId: json["business_id"],
        orderId: json["order_id"],
      );

  Map<String, dynamic> toJson() => {
        "business_name": businessName,
        "business_id": businessId,
        "order_id": orderId,
      };
}
