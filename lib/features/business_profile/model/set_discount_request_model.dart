import 'dart:convert';

class SetDiscountRequestModel {
  int? businessId;
  int? setFirstTimeDiscount;
  int? setRegularDiscount;
  int? minOrder;
  int? setExpiry;
  String? token;
  int? platformFeeRupees;
  int? gatewayCharges;
  int? reverseGatewayCharges;

  SetDiscountRequestModel({
    this.businessId,
    this.setFirstTimeDiscount,
    this.setRegularDiscount,
    this.minOrder,
    this.setExpiry,
    this.token,
    this.platformFeeRupees,
    this.gatewayCharges,
    this.reverseGatewayCharges,
  });

  factory SetDiscountRequestModel.fromRawJson(String str) =>
      SetDiscountRequestModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SetDiscountRequestModel.fromJson(Map<String, dynamic> json) =>
      SetDiscountRequestModel(
        businessId: json["business_id"],
        setRegularDiscount: json["set_regular_discount"],
        setFirstTimeDiscount: json["set_first_time_discount"],
        minOrder: json["min_order"],
        setExpiry: json["set_expiry"],
        token: json["token"],
        platformFeeRupees: json["platform_fee_rupees"],
        gatewayCharges: json["gateway_charges"],
        reverseGatewayCharges: json["reverse_gateway_charges"],
      );

  Map<String, dynamic> toJson() => {
        "business_id": businessId,
        "set_first_time_discount": setFirstTimeDiscount,
        "set_regular_discount": setRegularDiscount,
        "min_order": minOrder,
        "set_expiry": setExpiry,
        "token": token,
        "platform_fee_rupees": platformFeeRupees,
        "gateway_charges": gatewayCharges,
        "reverse_gateway_charges": reverseGatewayCharges,
      };
}
