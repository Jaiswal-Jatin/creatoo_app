import 'dart:convert';

class ReportResponse {
  bool? status;
  String? message;

  ReportResponse({
    this.status,
    this.message,
  });

  factory ReportResponse.fromRawJson(String str) =>
      ReportResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ReportResponse.fromJson(Map<String, dynamic> json) => ReportResponse(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}
