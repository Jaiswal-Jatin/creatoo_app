import 'dart:convert';

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is bool) return value ? 1 : 0;
  if (value is String) return int.tryParse(value);
  return null;
}

class BusinessDescriptionResponseModel {
  bool? status;
  String? message;
  Data? data;

  BusinessDescriptionResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory BusinessDescriptionResponseModel.fromRawJson(String str) => BusinessDescriptionResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusinessDescriptionResponseModel.fromJson(Map<String, dynamic> json) => BusinessDescriptionResponseModel(
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
  dynamic name;
  dynamic businessQrId;
  String? businessName;
  String? businessFullname;
  dynamic mobile;
  dynamic email;
  String? businessEmail;
  String? businessArea;
  String? businessAddress;
  String? businessSiteUrl;
  String? businessDesignation;
  String? gstNumber;
  dynamic businessTypeId;
  int? roleId;
  dynamic instagramLink;
  dynamic bio;
  int? otp;
  int? isActive;
  dynamic emailVerifiedAt;
  String? timeFrom;
  String? timeTo;
  String? pricingRangeText;
  dynamic menuCard1;
  dynamic menuCard2;
  dynamic menuCard3;
  dynamic menuCard4;
  dynamic menuCard5;
  String? businessImage1;
  String? businessImage2;
  String? businessImage3;
  dynamic businessImage4;
  dynamic businessImage5;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? businessMobile;
  int? isTop;
  dynamic address;
  dynamic userImage;
  String? businessImage;
  dynamic instagramUsername;
  int? wallet;
  int? userCreatooPoints;
  int? setFirstTimeDiscount;
  int? setRegularDiscount;
  int? minOrder;
  int? setExpiry;
  dynamic creatooNote;
  dynamic maxRedemption;
  dynamic paymentMobileNumber;
  dynamic upiId;
  dynamic bankAccountNumber;
  dynamic ifsc;
  dynamic bankName;
  dynamic branchName;
  dynamic defaultMethod;
  dynamic lastOrderId;
  dynamic instagramFullname;
  dynamic followingCount;
  dynamic followerCount;
  dynamic mediaCount;
  dynamic engagementRate;
  dynamic avgLikes;
  dynamic avgComments;
  dynamic avgActivity;
  String? isInstaVerified;
  dynamic verificationNote;
  dynamic profileImage;

  Data({
    this.id,
    this.name,
    this.businessQrId,
    this.businessName,
    this.businessFullname,
    this.mobile,
    this.email,
    this.businessEmail,
    this.businessAddress,
    this.businessArea,
    this.businessSiteUrl,
    this.businessDesignation,
    this.gstNumber,
    this.businessTypeId,
    this.roleId,
    this.instagramLink,
    this.bio,
    this.otp,
    this.isActive,
    this.emailVerifiedAt,
    this.timeFrom,
    this.timeTo,
    this.pricingRangeText,
    this.menuCard1,
    this.menuCard2,
    this.menuCard3,
    this.menuCard4,
    this.menuCard5,
    this.businessImage1,
    this.businessImage2,
    this.businessImage3,
    this.businessImage4,
    this.businessImage5,
    this.createdAt,
    this.updatedAt,
    this.businessMobile,
    this.isTop,
    this.address,
    this.userImage,
    this.businessImage,
    this.instagramUsername,
    this.wallet,
    this.userCreatooPoints,
    this.setFirstTimeDiscount,
    this.setRegularDiscount,
    this.minOrder,
    this.setExpiry,
    this.creatooNote,
    this.maxRedemption,
    this.paymentMobileNumber,
    this.upiId,
    this.bankAccountNumber,
    this.ifsc,
    this.bankName,
    this.branchName,
    this.defaultMethod,
    this.lastOrderId,
    this.instagramFullname,
    this.followingCount,
    this.followerCount,
    this.mediaCount,
    this.engagementRate,
    this.avgLikes,
    this.avgComments,
    this.avgActivity,
    this.isInstaVerified,
    this.verificationNote,
    this.profileImage,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        name: json["name"],
        businessQrId: json["business_qr_id"],
        businessName: json["business_name"],
        businessFullname: json["business_fullname"],
        mobile: json["mobile"],
        email: json["email"],
        businessEmail: json["business_email"],
        businessArea: json["business_area"],
        businessAddress: json["business_address"],
        businessSiteUrl: json["business_site_url"],
        businessDesignation: json["business_designation"],
        gstNumber: json["gst_number"],
        businessTypeId: json["business_type_id"],
        roleId: json["role_id"],
        instagramLink: json["instagram_link"],
        bio: json["bio"],
        otp: json["otp"],
        isActive: _toInt(json["is_active"]),
        emailVerifiedAt: json["email_verified_at"],
        timeFrom: json["time_from"],
        timeTo: json["time_to"],
        pricingRangeText: json["pricing_range_text"],
        menuCard1: json["menu_card_1"],
        menuCard2: json["menu_card_2"],
        menuCard3: json["menu_card_3"],
        menuCard4: json["menu_card_4"],
        menuCard5: json["menu_card_5"],
        businessImage1: json["business_image_1"],
        businessImage2: json["business_image_2"],
        businessImage3: json["business_image_3"],
        businessImage4: json["business_image_4"],
        businessImage5: json["business_image_5"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        businessMobile: json["business_mobile"],
        isTop: _toInt(json["is_top"]),
        address: json["address"],
        userImage: json["user_image"],
        businessImage: json["business_image"],
        instagramUsername: json["instagram_username"],
        wallet: json["wallet"],
        userCreatooPoints: json["user_creatoo_points"],
        setFirstTimeDiscount: json["set_first_time_discount"],
        setRegularDiscount: json["set_regular_discount"],
        minOrder: json["min_order"],
        setExpiry: json["set_expiry"],
        creatooNote: json["creatoo_note"],
        maxRedemption: json["max_redemption"],
        paymentMobileNumber: json["payment_mobile_number"],
        upiId: json["upi_id"],
        bankAccountNumber: json["bank_account_number"],
        ifsc: json["ifsc"],
        bankName: json["bank_name"],
        branchName: json["branch_name"],
        defaultMethod: json["default_method"],
        lastOrderId: json["last_order_id"],
        instagramFullname: json["instagram_fullname"],
        followingCount: json["following_count"],
        followerCount: json["follower_count"],
        mediaCount: json["media_count"],
        engagementRate: json["engagement_rate"],
        avgLikes: json["avg_likes"],
        avgComments: json["avg_comments"],
        avgActivity: json["avg_activity"],
        isInstaVerified: json["is_insta_verified"],
        verificationNote: json["verification_note"],
        profileImage: json["profile_image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "business_qr_id": businessQrId,
        "business_name": businessName,
        "business_fullname": businessFullname,
        "mobile": mobile,
        "email": email,
        "business_email": businessEmail,
        "business_area": businessArea,
        "business_address": businessAddress,
        "business_site_url": businessSiteUrl,
        "business_designation": businessDesignation,
        "gst_number": gstNumber,
        "business_type_id": businessTypeId,
        "role_id": roleId,
        "instagram_link": instagramLink,
        "bio": bio,
        "otp": otp,
        "is_active": isActive,
        "email_verified_at": emailVerifiedAt,
        "time_from": timeFrom,
        "time_to": timeTo,
        "pricing_range_text": pricingRangeText,
        "menu_card_1": menuCard1,
        "menu_card_2": menuCard2,
        "menu_card_3": menuCard3,
        "menu_card_4": menuCard4,
        "menu_card_5": menuCard5,
        "business_image_1": businessImage1,
        "business_image_2": businessImage2,
        "business_image_3": businessImage3,
        "business_image_4": businessImage4,
        "business_image_5": businessImage5,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "business_mobile": businessMobile,
        "is_top": isTop,
        "address": address,
        "user_image": userImage,
        "business_image": businessImage,
        "instagram_username": instagramUsername,
        "wallet": wallet,
        "user_creatoo_points": userCreatooPoints,
        "set_first_time_discount": setFirstTimeDiscount,
        "set_regular_discount": setRegularDiscount,
        "min_order": minOrder,
        "set_expiry": setExpiry,
        "creatoo_note": creatooNote,
        "max_redemption": maxRedemption,
        "payment_mobile_number": paymentMobileNumber,
        "upi_id": upiId,
        "bank_account_number": bankAccountNumber,
        "ifsc": ifsc,
        "bank_name": bankName,
        "branch_name": branchName,
        "default_method": defaultMethod,
        "last_order_id": lastOrderId,
        "instagram_fullname": instagramFullname,
        "following_count": followingCount,
        "follower_count": followerCount,
        "media_count": mediaCount,
        "engagement_rate": engagementRate,
        "avg_likes": avgLikes,
        "avg_comments": avgComments,
        "avg_activity": avgActivity,
        "is_insta_verified": isInstaVerified,
        "verification_note": verificationNote,
        "profile_image": profileImage,
      };
}
