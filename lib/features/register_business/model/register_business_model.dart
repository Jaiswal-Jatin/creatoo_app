import 'dart:convert';

class RegisterBusinessModel {
  int? id;
  String? businessName;
  String? businessFullname;
  String? businessMobile;
  String? businessEmail;
  String? businessArea;
  String? businessAddress;
  String? businessSiteUrl;
  String? businessDesignation;
  String? gstNumber;
  String? businessType;
  String? businessImage;
  int? roleId;
  // String? token;

  RegisterBusinessModel({
    this.id,
    this.businessName,
    this.businessFullname,
    this.businessMobile,
    this.businessEmail,
    this.businessArea,
    this.businessAddress,
    this.businessSiteUrl,
    this.businessDesignation,
    this.gstNumber,
    this.businessType,
    this.businessImage,
    this.roleId,
    // this.token,
  });

  factory RegisterBusinessModel.fromRawJson(String str) => RegisterBusinessModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RegisterBusinessModel.fromJson(Map<String, dynamic> json) => RegisterBusinessModel(
        id: json["id"],
        businessName: json["business_name"],
        businessFullname: json["business_fullname"],
        businessMobile: json["business_mobile"],
        businessEmail: json["business_email"],
        businessArea: json["business_area"], businessAddress: json["business_address"],
        businessSiteUrl: json["business_site_url"],
        businessDesignation: json["business_designation"],
        gstNumber: json["gst_number"],
        businessType: json["business_type"],
        businessImage: json["business_image"],
        roleId: json["role_id"],
        // token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "business_name": businessName,
        "business_fullname": businessFullname,
        "business_mobile": businessMobile,
        "business_email": businessEmail,
        "business_area": businessArea,
        "business_address": businessAddress,
        "business_site_url": businessSiteUrl,
        "business_designation": businessDesignation,
        "gst_number": gstNumber,
        "business_type": businessType,
        "business_image": businessImage,
        "role_id": roleId,
        // "token": token,
      };
}
