import 'dart:convert';

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is bool) return value ? 1 : 0;
  if (value is String) return int.tryParse(value);
  return null;
}

class BusinessDetailsResponseModel {
  bool? status;
  String? message;
  BusinessDescription? data;

  BusinessDetailsResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory BusinessDetailsResponseModel.fromRawJson(String str) => BusinessDetailsResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusinessDetailsResponseModel.fromJson(Map<String, dynamic> json) => BusinessDetailsResponseModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : BusinessDescription.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class BusinessDescription {
  int? id;
  String? businessFullname;
  String? businessName;
  dynamic businessEmail;
  String? businessMobile;
  String? businessAddress;
  String? businessArea;
  dynamic businessSiteUrl;
  String? businessImage;
  dynamic gstNumber;
  String? businessDesignation;
  int? isActive;
  int? roleId;
  String? timeFrom;
  String? timeTo;
  String? pricingRangeText;
  String? menuCard1;
  String? menuCard2;
  String? menuCard3;
  dynamic menuCard4;
  dynamic menuCard5;
  String? businessImage1;
  String? businessImage2;
  String? businessImage3;
  dynamic businessImage4;
  dynamic businessImage5;
  int? setFirstTimeDiscount;
  int? setRegularDiscount;
  int? minOrder;
  int? setExpiry;
  AverageRatings? averageRatings;
  int? totalReviews;
  List<String>? reviewText;

  BusinessDescription({
    this.id,
    this.businessFullname,
    this.businessName,
    this.businessEmail,
    this.businessMobile,
    this.businessAddress,
    this.businessArea,
    this.businessSiteUrl,
    this.businessImage,
    this.gstNumber,
    this.businessDesignation,
    this.isActive,
    this.roleId,
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
    this.setFirstTimeDiscount,
    this.setRegularDiscount,
    this.minOrder,
    this.setExpiry,
    this.averageRatings,
    this.totalReviews,
    this.reviewText,
  });

  factory BusinessDescription.fromRawJson(String str) => BusinessDescription.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusinessDescription.fromJson(Map<String, dynamic> json) => BusinessDescription(
        id: json["id"],
        businessFullname: json["business_fullname"],
        businessName: json["business_name"],
        businessEmail: json["business_email"],
        businessMobile: json["business_mobile"],
        businessAddress: json["business_address"],
        businessArea: json["business_area"],
        businessSiteUrl: json["business_site_url"],
        businessImage: json["business_image"],
        gstNumber: json["gst_number"],
        businessDesignation: json["business_designation"],
        isActive: _toInt(json["is_active"]),
        roleId: json["role_id"],
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
        setFirstTimeDiscount: json["set_first_time_discount"],
        setRegularDiscount: json["set_regular_discount"],
        minOrder: json["min_order"],
        setExpiry: json["set_expiry"],
        averageRatings: json["average_ratings"] == null ? null : AverageRatings.fromJson(json["average_ratings"]),
        totalReviews: json["total_reviews"],
        reviewText: json["review_text"] == null ? [] : List<String>.from(json["review_text"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "business_fullname": businessFullname,
        "business_name": businessName,
        "business_email": businessEmail,
        "business_mobile": businessMobile,
        "business_address": businessAddress,
        "business_area": businessArea,
        "business_site_url": businessSiteUrl,
        "business_image": businessImage,
        "gst_number": gstNumber,
        "business_designation": businessDesignation,
        "is_active": isActive,
        "role_id": roleId,
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
        "set_regular_discount": setRegularDiscount,
        "set_first_time_discount": setFirstTimeDiscount,
        "min_order": minOrder,
        "set_expiry": setExpiry,
        "average_ratings": averageRatings?.toJson(),
        "total_reviews": totalReviews,
        "review_text": reviewText == null ? [] : List<dynamic>.from(reviewText!.map((x) => x)),
      };
}

class AverageRatings {
  String? avgExperience;
  String? avgExpectation;
  String? avgInteraction;
  String? avgRecommend;
  String? avgFairMoney;

  AverageRatings({
    this.avgExperience,
    this.avgExpectation,
    this.avgInteraction,
    this.avgRecommend,
    this.avgFairMoney,
  });

  factory AverageRatings.fromRawJson(String str) => AverageRatings.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AverageRatings.fromJson(Map<String, dynamic> json) => AverageRatings(
        avgExperience: json["avg_experience"],
        avgExpectation: json["avg_expectation"],
        avgInteraction: json["avg_interaction"],
        avgRecommend: json["avg_recommend"],
        avgFairMoney: json["avg_fair_money"],
      );

  Map<String, dynamic> toJson() => {
        "avg_experience": avgExperience,
        "avg_expectation": avgExpectation,
        "avg_interaction": avgInteraction,
        "avg_recommend": avgRecommend,
        "avg_fair_money": avgFairMoney,
      };
}
