import 'dart:convert';

class OtpResponse {
  bool? status;
  String? message;
  Data? data;

  OtpResponse({
    this.status,
    this.message,
    this.data,
  });

  factory OtpResponse.fromRawJson(String str) => OtpResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OtpResponse.fromJson(Map<String, dynamic> json) => OtpResponse(
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
  int? otp;

  Data({
    this.otp,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    otp: json["otp"],
  );

  Map<String, dynamic> toJson() => {
    "otp": otp,
  };
}
