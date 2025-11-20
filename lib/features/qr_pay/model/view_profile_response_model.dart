import 'dart:convert';

class ViewProfileResponseModel {
  bool? status;
  String? message;
  BusinessData? data;

  ViewProfileResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory ViewProfileResponseModel.fromRawJson(String str) => ViewProfileResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ViewProfileResponseModel.fromJson(Map<String, dynamic> json) => ViewProfileResponseModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : BusinessData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class BusinessData {
  int? id;
  String? businessFullname;
  String? businessName;
  dynamic businessEmail;
  String? businessMobile;
  String? businessAddress;
  dynamic businessSiteUrl;
  String? businessImage;
  dynamic gstNumber;
  String? businessDesignation;
  int? isActive;
  int? roleId;

  BusinessData({
    this.id,
    this.businessFullname,
    this.businessName,
    this.businessEmail,
    this.businessMobile,
    this.businessAddress,
    this.businessSiteUrl,
    this.businessImage,
    this.gstNumber,
    this.businessDesignation,
    this.isActive,
    this.roleId,
  });

  factory BusinessData.fromRawJson(String str) => BusinessData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusinessData.fromJson(Map<String, dynamic> json) => BusinessData(
        id: json["id"],
        businessFullname: json["business_fullname"],
        businessName: json["business_name"],
        businessEmail: json["business_email"],
        businessMobile: json["business_mobile"],
        businessAddress: json["business_address"],
        businessSiteUrl: json["business_site_url"],
        businessImage: json["business_image"],
        gstNumber: json["gst_number"],
        businessDesignation: json["business_designation"],
        isActive: json["is_active"],
        roleId: json["role_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "business_fullname": businessFullname,
        "business_name": businessName,
        "business_email": businessEmail,
        "business_mobile": businessMobile,
        "business_address": businessAddress,
        "business_site_url": businessSiteUrl,
        "business_image": businessImage,
        "gst_number": gstNumber,
        "business_designation": businessDesignation,
        "is_active": isActive,
        "role_id": roleId,
      };
}
