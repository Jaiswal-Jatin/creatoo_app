import 'package:creatoo/core.dart';

class VerifyOtpResponse {
  bool? status;
  String? message;
  UserData? data;

  VerifyOtpResponse({
    this.status,
    this.message,
    this.data,
  });

  factory VerifyOtpResponse.fromRawJson(String str) =>
      VerifyOtpResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) =>
      VerifyOtpResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : UserData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class UserData {
  String? token;
  int? id;
  String? name;
  String? email;
  String? mobile;
  dynamic address;
  int? isActive;
  int? isRegistered;
  String? image;
  String? gst;
  int? roleId;
  int? instagramVerificationStatus;

  UserData({
    this.token,
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.address,
    this.isActive,
    this.isRegistered,
    this.image,
    this.gst,
    this.roleId,
    this.instagramVerificationStatus,
  });

  // Helper method to convert bool/int to int
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is bool) return value ? 1 : 0;
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory UserData.fromRawJson(String str) =>
      UserData.fromJson(json.decode(str));

  factory UserData.fromBusinessRawJson(String str) =>
      UserData.fromBusinessJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        token: json["token"],
        roleId: json["role_id"],
        id: json["id"],
        name: json["role_id"] == Constants.creatorUser
            ? json["name"]
            : (json["business_name"] ?? json["business_fullname"]),
        email: json["role_id"] == Constants.creatorUser
            ? json["email"]
            : json["business_email"],
        mobile: json["role_id"] == Constants.creatorUser
            ? json["mobile"]
            : json["business_mobile"],
        address: json["role_id"] == Constants.creatorUser
            ? json["address"]
            : (json["business_area"] ?? json["business_address"]),
        isActive: _toInt(json["is_active"]),
        isRegistered: _toInt(json["is_registered"]),
      );

  factory UserData.fromCreatorJson(Map<String, dynamic> json) => UserData(
        token: json["token"],
        id: json["id"],
        name: json["name"],
        email: json["email"],
        mobile: json["mobile"],
        address: json["address"],
        isActive: _toInt(json["is_active"]),
        isRegistered: _toInt(json["is_registered"]),
        roleId: json["role_id"],
      );

  factory UserData.fromBusinessJson(Map<String, dynamic> json) => UserData(
        token: json["token"],
        id: json["id"],
        name: json["business_name"] ?? json["business_fullname"],
        email: json["business_email"],
        mobile: json["business_mobile"],
        address: json["business_area"] ?? json["business_address"],
        isActive: _toInt(json["is_active"]),
        isRegistered: _toInt(json["is_registered"]),
        roleId: json["role_id"],
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "id": id,
        "name": name,
        "email": email,
        "mobile": mobile,
        "address": address,
        "is_active": isActive,
        "is_registered": isRegistered,
        "role_id": roleId,
      };
}
