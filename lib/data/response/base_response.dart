import 'dart:convert';

class BaseResponse {
  bool? status;
  String message;
  List<dynamic>? data;

  BaseResponse({
    this.status,
    this.message = "",
    this.data,
  });

  factory BaseResponse.fromRawJson(String str) => BaseResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BaseResponse.fromJson(Map<String, dynamic> json) => BaseResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<dynamic>.from(json["data"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x)),
  };
}
