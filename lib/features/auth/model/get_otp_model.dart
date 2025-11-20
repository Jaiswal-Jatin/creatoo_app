import 'dart:convert';

class GetOtp {
  String? mobile;
  String? otp;
  String? isVerified;
  String? rememberToken;
  bool isCreator;
  GetOtp({
    this.mobile,
    this.otp,
    this.isVerified,
    this.rememberToken,
    this.isCreator = true,
  });

  factory GetOtp.fromRawJson(String str) => GetOtp.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetOtp.fromJson(Map<String, dynamic> json) => GetOtp(
    mobile: json["mobile"],
    otp: json["otp"],
    isVerified: json["is_verified"],
    rememberToken: json["remember_token"],
  );

  Map<String, dynamic> toJson() => {
    "mobile": mobile,
    "otp": otp,
    "is_verified": isVerified,
    "remember_token": rememberToken,
  };
}
