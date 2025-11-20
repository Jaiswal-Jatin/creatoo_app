import 'dart:convert';

class RequestCreatooPointsModel {
  int? creatorId;
  int? businessId;
  String? image;
  num? points;
  num? billAmount;
  String? token;

  RequestCreatooPointsModel({
    this.creatorId,
    this.businessId,
    this.image,
    this.points,
    this.billAmount,
    this.token,
  });

  factory RequestCreatooPointsModel.fromRawJson(String str) => RequestCreatooPointsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RequestCreatooPointsModel.fromJson(Map<String, dynamic> json) => RequestCreatooPointsModel(
        creatorId: json["creator_id"],
        businessId: json["business_id"],
        image: json["image"],
        points: json["points"],
        billAmount: json["bill_amount"],
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "creator_id": creatorId,
        "business_id": businessId,
        "image": image,
        "points": points,
        "bill_amount": billAmount,
        "token": token,
      };
}
