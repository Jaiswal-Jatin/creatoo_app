import 'dart:convert';

class BusinessProfileResponse {
  bool? status;
  String? message;
  Data? data;

  BusinessProfileResponse({
    this.status,
    this.message,
    this.data,
  });

  factory BusinessProfileResponse.fromRawJson(String str) => BusinessProfileResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusinessProfileResponse.fromJson(Map<String, dynamic> json) => BusinessProfileResponse(
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
  String? businessFullname;
  String? businessName;
  String? businessEmail;
  String? businessMobile;
  String? businessAddress;
  String? businessArea;
  String? businessSiteUrl;
  String? businessImage;
  String? gstNumber;
  String? businessDesignation;
  int? isActive;
  int? roleId;
  String? timeFrom;
  String? timeTo;
  String? pricingRangeText;
  String? menuCard1;
  String? menuCard2;
  String? menuCard3;
  String? menuCard4;
  String? menuCard5;
  String? businessImage1;
  String? businessImage2;
  String? businessImage3;
  String? businessImage4;
  String? businessImage5;
  int? setFirstTimeDiscount;
  int? setRegularDiscount;
  int? minOrder;
  int? setExpiry;

  Data({
    this.id,
    this.businessFullname,
    this.businessName,
    this.businessEmail,
    this.businessMobile,
    this.businessArea,
    this.businessAddress,
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
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        businessFullname: json["business_fullname"],
        businessName: json["business_name"],
        businessEmail: json["business_email"],
        businessMobile: json["business_mobile"],
        businessArea: json["business_area"],
        businessAddress: json["business_address"],
        businessSiteUrl: json["business_site_url"],
        businessImage: json["business_image"],
        gstNumber: json["gst_number"],
        businessDesignation: json["business_designation"],
        isActive: json["is_active"],
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
        "set_first_time_discount": setFirstTimeDiscount,
        "set_regular_discount": setRegularDiscount,
        "min_order": minOrder,
        "set_expiry": setExpiry,
      };
}
