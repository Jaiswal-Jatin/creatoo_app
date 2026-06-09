import 'dart:convert';

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is bool) return value ? 1 : 0;
  if (value is String) return int.tryParse(value);
  return null;
}

String? _toString(dynamic value) {
  if (value == null) return null;
  return value.toString();
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

  factory BusinessDetailsResponseModel.fromRawJson(String str) =>
      BusinessDetailsResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusinessDetailsResponseModel.fromJson(Map<String, dynamic> json) =>
      BusinessDetailsResponseModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : BusinessDescription.fromJson(json["data"]),
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
  List<Review>? reviews;
  List<BusinessAssociate>? associates;
  String? upiId;
  String? businessCategory;
  Map<String, dynamic>? categoryAttributes;

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
    this.reviews,
    this.associates,
    this.upiId,
    this.businessCategory,
    this.categoryAttributes,
  });

  factory BusinessDescription.fromRawJson(String str) =>
      BusinessDescription.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusinessDescription.fromJson(Map<String, dynamic> json) {
    var reviewsList = json["reviews"] == null
        ? <Review>[]
        : List<Review>.from(json["reviews"]!.map((x) => Review.fromJson(x)));

    var avgRatings = json["average_ratings"] == null
        ? AverageRatings()
        : AverageRatings.fromJson(json["average_ratings"]);

    // If ratings are missing in the summary, calculate them from reviews
    if (reviewsList.isNotEmpty) {
      if (avgRatings.avgExperience == null || avgRatings.avgExperience == "0") {
        double total = reviewsList.fold(
            0, (sum, item) => sum + (item.experience?.toDouble() ?? 0));
        avgRatings.avgExperience =
            (total / reviewsList.length).toStringAsFixed(1);
      }
      if (avgRatings.avgExpectation == null ||
          avgRatings.avgExpectation == "0") {
        double total = reviewsList.fold(
            0, (sum, item) => sum + (item.expectation?.toDouble() ?? 0));
        avgRatings.avgExpectation =
            (total / reviewsList.length).toStringAsFixed(1);
      }
      if (avgRatings.avgInteraction == null ||
          avgRatings.avgInteraction == "0") {
        double total = reviewsList.fold(
            0, (sum, item) => sum + (item.interaction?.toDouble() ?? 0));
        avgRatings.avgInteraction =
            (total / reviewsList.length).toStringAsFixed(1);
      }
      if (avgRatings.avgRecommend == null || avgRatings.avgRecommend == "0") {
        double total = reviewsList.fold(
            0, (sum, item) => sum + (item.recommend?.toDouble() ?? 0));
        avgRatings.avgRecommend =
            "${((total / reviewsList.length) * 100).toStringAsFixed(0)}%";
      }
      if (avgRatings.avgFairMoney == null || avgRatings.avgFairMoney == "0") {
        double total = reviewsList.fold(
            0, (sum, item) => sum + (item.fairMoney?.toDouble() ?? 0));
        avgRatings.avgFairMoney =
            "${((total / reviewsList.length) * 100).toStringAsFixed(0)}%";
      }
    }

    return BusinessDescription(
      id: _toInt(json["id"]),
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
      roleId: _toInt(json["role_id"]),
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
      setFirstTimeDiscount: _toInt(json["set_first_time_discount"]),
      setRegularDiscount: _toInt(json["set_regular_discount"]),
      minOrder: _toInt(json["min_order"]),
      setExpiry: _toInt(json["set_expiry"]),
      averageRatings: avgRatings,
      totalReviews: _toInt(json["total_reviews"]),
      reviews: reviewsList,
      associates: json["associates"] == null
          ? []
          : List<BusinessAssociate>.from(
              json["associates"]!.map((x) => BusinessAssociate.fromJson(x))),
      upiId: json["upi_id"],
      businessCategory: json["business_category"],
      categoryAttributes: json["category_attributes"] != null
          ? (json["category_attributes"] is String
              ? jsonDecode(json["category_attributes"]) as Map<String, dynamic>
              : Map<String, dynamic>.from(json["category_attributes"]))
          : null,
    );
  }

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
        "reviews": reviews == null
            ? []
            : List<dynamic>.from(reviews!.map((x) => x.toJson())),
        "associates": associates == null
            ? []
            : List<dynamic>.from(associates!.map((x) => x.toJson())),
        "upi_id": upiId,
        "business_category": businessCategory,
        "category_attributes": categoryAttributes,
      };
}

class Review {
  int? experience;
  int? expectation;
  int? recommend;
  int? fairMoney;
  int? interaction;
  String? reviewText;

  Review({
    this.experience,
    this.expectation,
    this.recommend,
    this.fairMoney,
    this.interaction,
    this.reviewText,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        experience: _toInt(json["experience"]),
        expectation: _toInt(json["expectation"]),
        recommend: _toInt(json["recommend"]),
        fairMoney: _toInt(json["fair_money"]),
        interaction: _toInt(json["interaction"]),
        reviewText: json["review_text"],
      );

  Map<String, dynamic> toJson() => {
        "experience": experience,
        "expectation": expectation,
        "recommend": recommend,
        "fair_money": fairMoney,
        "interaction": interaction,
        "review_text": reviewText,
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

  factory AverageRatings.fromRawJson(String str) =>
      AverageRatings.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AverageRatings.fromJson(Map<String, dynamic> json) => AverageRatings(
        avgExperience: _toString(json["avg_experience"]),
        avgExpectation: _toString(json["avg_expectation"]),
        avgInteraction: _toString(json["avg_interaction"]),
        avgRecommend: _toString(json["avg_recommend"]),
        avgFairMoney: _toString(json["avg_fair_money"]),
      );

  Map<String, dynamic> toJson() => {
        "avg_experience": avgExperience,
        "avg_expectation": avgExpectation,
        "avg_interaction": avgInteraction,
        "avg_recommend": avgRecommend,
        "avg_fair_money": avgFairMoney,
      };
}

class BusinessAssociate {
  int? id;
  String? businessName;
  String? businessFullname;
  String? businessImage;
  String? businessAddress;
  String? businessArea;
  String? businessDesignation;
  String? timeFrom;
  String? timeTo;

  BusinessAssociate({
    this.id,
    this.businessName,
    this.businessFullname,
    this.businessImage,
    this.businessAddress,
    this.businessArea,
    this.businessDesignation,
    this.timeFrom,
    this.timeTo,
  });

  factory BusinessAssociate.fromJson(Map<String, dynamic> json) =>
      BusinessAssociate(
        id: _toInt(json["id"]),
        businessName: json["business_name"],
        businessFullname: json["business_fullname"],
        businessImage: json["business_image"],
        businessAddress: json["business_address"],
        businessArea: json["business_area"],
        businessDesignation: json["business_designation"],
        timeFrom: json["time_from"],
        timeTo: json["time_to"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "business_name": businessName,
        "business_fullname": businessFullname,
        "business_image": businessImage,
        "business_address": businessAddress,
        "business_area": businessArea,
        "business_designation": businessDesignation,
        "time_from": timeFrom,
        "time_to": timeTo,
      };
}
