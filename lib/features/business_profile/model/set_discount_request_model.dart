import 'dart:convert';

class SetDiscountRequestModel {
  int? businessId;
  int? setFirstTimeDiscount;
  int? setRegularDiscount;
  int? minOrder;
  int? setExpiry;
  String? token;

  SetDiscountRequestModel({
    this.businessId,
    this.setFirstTimeDiscount,
    this.setRegularDiscount,
    this.minOrder,
    this.setExpiry,
    this.token,
  });

  factory SetDiscountRequestModel.fromRawJson(String str) => SetDiscountRequestModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SetDiscountRequestModel.fromJson(Map<String, dynamic> json) => SetDiscountRequestModel(
        businessId: json["business_id"],
        setRegularDiscount: json["set_regular_discount"],
        setFirstTimeDiscount: json["set_first_time_discount"],
        minOrder: json["min_order"],
        setExpiry: json["set_expiry"],
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "business_id": businessId,
        "set_first_time_discount": setFirstTimeDiscount,
        "set_regular_discount": setRegularDiscount,
        "min_order": minOrder,
        "set_expiry": setExpiry,
        "token": token,
      };
}
