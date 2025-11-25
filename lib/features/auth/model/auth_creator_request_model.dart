import 'dart:convert';

class AuthCreatorRequestModel {
  String? mobile;
  int? isVerified;
  String? otp;
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
        otp: json["otp"]?.toString(),
        rememberToken: json["remember_token"]?.toString() ?? "",
        deviceId: json["device_id"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "mobile": mobile?.toString(),
        "is_verified": isVerified,
        "otp": otp?.toString(),
        "remember_token": rememberToken?.toString(),
        "device_id": deviceId?.toString(),
      };
}
