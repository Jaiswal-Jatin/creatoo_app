// To parse this JSON data, do
//
//     final scannerModelResponse = scannerModelResponseFromJson(jsonString);

import 'dart:convert';

ScannerModelResponse scannerModelResponseFromJson(String str) => ScannerModelResponse.fromJson(json.decode(str));

String scannerModelResponseToJson(ScannerModelResponse data) => json.encode(data.toJson());

class ScannerModelResponse {
  final bool? status;
  final String? message;
  final Data? data;

  ScannerModelResponse({
    this.status,
    this.message,
    this.data,
  });

  ScannerModelResponse copyWith({
    bool? status,
    String? message,
    Data? data,
  }) =>
      ScannerModelResponse(
        status: status ?? this.status,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory ScannerModelResponse.fromJson(Map<String, dynamic> json) => ScannerModelResponse(
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
  final int? id;
  final int? setDiscount;
  final int? minOrder;
  final int? setExpiry;
  final String? note;

  Data({
    this.id,
    this.setDiscount,
    this.minOrder,
    this.setExpiry,
    this.note,
  });

  Data copyWith({
    int? id,
    int? setDiscount,
    int? minOrder,
    int? setExpiry,
    String? note,
  }) =>
      Data(
        id: id ?? this.id,
        setDiscount: setDiscount ?? this.setDiscount,
        minOrder: minOrder ?? this.minOrder,
        setExpiry: setExpiry ?? this.setExpiry,
        note: note ?? this.note,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        setDiscount: json["set_discount"],
        minOrder: json["min_order"],
        setExpiry: json["set_expiry"],
        note: json["creatoo_note"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "set_discount": setDiscount,
        "min_order": minOrder,
        "set_expiry": setExpiry,
        "note": note,
      };
}
