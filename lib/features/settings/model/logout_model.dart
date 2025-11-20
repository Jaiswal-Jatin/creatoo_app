import 'dart:convert';

class LogoutResponse {
  bool? status;
  String? message;

  LogoutResponse({
    this.status,
    this.message,
  });

  factory LogoutResponse.fromRawJson(String str) => LogoutResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LogoutResponse.fromJson(Map<String, dynamic> json) => LogoutResponse(
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
  };
}
