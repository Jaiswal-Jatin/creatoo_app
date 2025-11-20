import 'dart:convert';

class ProcessPaymentStatusResponse {
  bool? status;
  String? message;
  dynamic data;

  ProcessPaymentStatusResponse({
    this.status,
    this.message,
    this.data,
  });

  factory ProcessPaymentStatusResponse.fromRawJson(String str) => ProcessPaymentStatusResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProcessPaymentStatusResponse.fromJson(Map<String, dynamic> json) => ProcessPaymentStatusResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data,
      };
}
