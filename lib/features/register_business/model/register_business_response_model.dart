import 'dart:convert';

class RegisterBusinessResponse {
  bool? status;
  String? message;
  Data? data;

  RegisterBusinessResponse({
    this.status,
    this.message,
    this.data,
  });

  factory RegisterBusinessResponse.fromRawJson(String str) => RegisterBusinessResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RegisterBusinessResponse.fromJson(Map<String, dynamic> json) => RegisterBusinessResponse(
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
  String? token;
  int? id;
  String? businessFullname;
  String? businessName;
  String? businessEmail;
  String? businessMobile;
  String? businessArea;
  String? businessAddress;
  String? businessDesignation;
  String? businessSiteUrl;
  dynamic businessTypeId;
  String? businessImage;
  String? gstNumber;
  int? roleId;

  Data({
    this.token,
    this.id,
    this.businessFullname,
    this.businessName,
    this.businessEmail,
    this.businessMobile,
    this.businessArea,
    this.businessAddress,
    this.businessDesignation,
    this.businessSiteUrl,
    this.businessTypeId,
    this.businessImage,
    this.gstNumber,
    this.roleId,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        token: json["token"],
        id: json["id"],
        businessFullname: json["business_fullname"],
        businessName: json["business_name"],
        businessEmail: json["business_email"],
        businessMobile: json["business_mobile"],
        businessArea: json["business_area"],
        businessAddress: json["business_address"],
        businessDesignation: json["business_designation"],
        businessSiteUrl: json["business_site_url"],
        businessTypeId: json["business_type_id"],
        businessImage: json["business_image"],
        gstNumber: json["gst_number"],
        roleId: json["role_id"],
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "id": id,
        "business_fullname": businessFullname,
        "business_name": businessName,
        "business_email": businessEmail,
        "business_mobile": businessMobile,
        "business_address": businessAddress,
        "business_area": businessArea,
        "business_designation": businessDesignation,
        "business_site_url": businessSiteUrl,
        "business_type_id": businessTypeId,
        "business_image": businessImage,
        "gst_number": gstNumber,
        "role_id": roleId,
      };
}
