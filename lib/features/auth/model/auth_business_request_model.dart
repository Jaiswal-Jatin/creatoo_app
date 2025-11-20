import 'dart:convert';

class AuthBusinessRequestModel {
  String? businessMobile;
  int? isVerified;
  int? otp;
  String? rememberToken;
  String? deviceId;

  AuthBusinessRequestModel({
    this.businessMobile,
    this.isVerified = 0,
    this.otp,
    this.rememberToken,
    this.deviceId,
  });

  factory AuthBusinessRequestModel.fromRawJson(String str) => AuthBusinessRequestModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AuthBusinessRequestModel.fromJson(Map<String, dynamic> json) => AuthBusinessRequestModel(
        businessMobile: json["business_mobile"],
        isVerified: json["is_verified"],
        otp: json["otp"] ?? 0,
        rememberToken: json["remember_token"] ?? "",
        deviceId: json["device_id"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "business_mobile": businessMobile,
        "is_verified": isVerified,
        "otp": otp,
        "remember_token": rememberToken,
        "device_id": deviceId,
      };
}
