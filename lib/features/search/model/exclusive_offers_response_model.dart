import 'dart:convert';

class ExclusiveOffersResponseModel {
  bool? status;
  String? message;
  ExclusiveOffersData? data;

  ExclusiveOffersResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory ExclusiveOffersResponseModel.fromRawJson(String str) =>
      ExclusiveOffersResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ExclusiveOffersResponseModel.fromJson(Map<String, dynamic> json) =>
      ExclusiveOffersResponseModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : ExclusiveOffersData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class ExclusiveOffersData {
  List<String>? premiumOffers;
  List<String>? eliteOffers;
  List<String>? coreOffers;
  String? businessTier;

  ExclusiveOffersData({
    this.premiumOffers,
    this.eliteOffers,
    this.coreOffers,
    this.businessTier,
  });

  factory ExclusiveOffersData.fromRawJson(String str) =>
      ExclusiveOffersData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ExclusiveOffersData.fromJson(Map<String, dynamic> json) =>
      ExclusiveOffersData(
        premiumOffers: json["premium"] == null
            ? []
            : List<String>.from(json["premium"].map((x) => x)),
        eliteOffers: json["elite"] == null
            ? []
            : List<String>.from(json["elite"].map((x) => x)),
        coreOffers: json["core"] == null
            ? []
            : List<String>.from(json["core"].map((x) => x)),
        businessTier: json["business_tier"],
      );

  Map<String, dynamic> toJson() => {
        "premium_offers":
            premiumOffers == null ? [] : List<dynamic>.from(premiumOffers!.map((x) => x)),
        "elite_offers":
            eliteOffers == null ? [] : List<dynamic>.from(eliteOffers!.map((x) => x)),
        "core_offers":
            coreOffers == null ? [] : List<dynamic>.from(coreOffers!.map((x) => x)),
        "business_tier": businessTier,
      };
}
