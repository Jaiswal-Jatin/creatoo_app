import 'dart:convert';

class SettingResponse {
  final bool? status;
  final String? message;
  final Setting? data;

  SettingResponse({
    this.status,
    this.message,
    this.data,
  });

  factory SettingResponse.fromRawJson(String str) => SettingResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SettingResponse.fromJson(Map<String, dynamic> json) => SettingResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : Setting.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Setting {
  int? id;
  double? cgstPercent;
  double? sgstPercent;
  double? igstPercent;
  double? platformFeePercent;
  int? creatooPoints;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? gstNumber;

  Setting({
    this.id,
    this.cgstPercent,
    this.sgstPercent,
    this.igstPercent,
    this.platformFeePercent,
    this.creatooPoints,
    this.createdAt,
    this.updatedAt,
    this.gstNumber,
  });

  factory Setting.fromRawJson(String str) => Setting.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Setting.fromJson(Map<String, dynamic> json) => Setting(
    id: json["id"],
    cgstPercent: double.parse(json["cgst_percent"]) ,
    sgstPercent: double.parse(json["sgst_percent"]) ,
    igstPercent: double.parse(json["igst_percent"]) ,
    platformFeePercent: double.parse(json["platform_fee_percent"]) ,
    creatooPoints: json["creatoo_points"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    gstNumber: json["gst_number"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "cgst_percent": cgstPercent,
    "sgst_percent": sgstPercent,
    "igst_percent": igstPercent,
    "platform_fee_percent": platformFeePercent,
    "creatoo_points": creatooPoints,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "gst_number": gstNumber,
  };
}
