import 'dart:convert';

class InstaVerificationResponse {
  final bool status;
  final String message;
  final Data data;

  InstaVerificationResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory InstaVerificationResponse.fromRawJson(String str) => InstaVerificationResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory InstaVerificationResponse.fromJson(Map<String, dynamic> json) => InstaVerificationResponse(
    status: json["status"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  final String isInstaVerfied;

  Data({
    required this.isInstaVerfied,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    isInstaVerfied: json["is_insta_verfied"],
  );

  Map<String, dynamic> toJson() => {
    "is_insta_verfied": isInstaVerfied,
  };
}
