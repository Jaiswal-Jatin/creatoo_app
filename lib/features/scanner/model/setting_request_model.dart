import 'dart:convert';

class BusinessSettings {
  int? businessId;
  int? setDiscount;
  int? minOrder;
  int? setExpiry;
  String? note;

  BusinessSettings({
    this.businessId,
    this.setDiscount,
    this.minOrder,
    this.setExpiry,
    this.note,
  });

  factory BusinessSettings.fromRawJson(String str) => BusinessSettings.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusinessSettings.fromJson(Map<String, dynamic> json) => BusinessSettings(
        businessId: json["business_id"],
        setDiscount: json["set_discount"],
        minOrder: json["min_order"],
        setExpiry: json["set_expiry"],
        note: json["note"],
      );

  Map<String, dynamic> toJson() => {
        "business_id": businessId,
        "set_discount": setDiscount,
        "min_order": minOrder,
        "set_expiry": setExpiry,
        "note": note,
      };
}
