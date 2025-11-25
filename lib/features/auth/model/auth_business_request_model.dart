import 'dart:convert';

class AuthBusinessRequestModel {
  String? businessMobile;
  int? isVerified;
  String? otp;
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
        otp: json["otp"]?.toString(),
        rememberToken: json["remember_token"]?.toString() ?? "",
        deviceId: json["device_id"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "business_mobile": businessMobile?.toString(),
        "is_verified": isVerified,
        "otp": otp?.toString(),
        "remember_token": rememberToken?.toString(),
        "device_id": deviceId?.toString(),
      };
}
