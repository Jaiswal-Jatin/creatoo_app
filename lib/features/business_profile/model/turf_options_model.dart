import 'dart:convert';

class TurfOptionsModel {
  bool? status;
  String? message;
  Map<String, List<String>>? data;

  TurfOptionsModel({this.status, this.message, this.data});

  factory TurfOptionsModel.fromRawJson(String str) =>
      TurfOptionsModel.fromJson(json.decode(str));

  factory TurfOptionsModel.fromJson(Map<String, dynamic> json) =>
      TurfOptionsModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] != null
            ? (json["data"] as Map<String, dynamic>).map(
                (k, v) => MapEntry(k, List<String>.from(v as List)),
              )
            : null,
      );
}
