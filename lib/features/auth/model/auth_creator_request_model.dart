import 'dart:convert';

class AuthCreatorRequestModel {
  String? mobile;
  int? isVerified;
  int? otp;
  String? rememberToken;
  String? deviceId;

  AuthCreatorRequestModel({
    this.mobile,
    this.isVerified = 0,
    this.otp,
    this.rememberToken,
    this.deviceId,
  });

  factory AuthCreatorRequestModel.fromRawJson(String str) => AuthCreatorRequestModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AuthCreatorRequestModel.fromJson(Map<String, dynamic> json) => AuthCreatorRequestModel(
        mobile: json["mobile"],
        isVerified: json["is_verified"],
        otp: json["otp"] ?? 0,
        rememberToken: json["remember_token"] ?? "",
        deviceId: json["device_id"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "mobile": mobile,
        "is_verified": isVerified,
        "otp": otp,
        "remember_token": rememberToken,
        "device_id": deviceId,
      };
}
