import 'dart:convert';

import 'package:creatoo/features/add_post_payment_summary/model/setting_response_model.dart';

class AddPostModel {
  String? name;
  String? description;
  int? duration;
  String? deliverable;
  int? followersRequired;
  int? workMode;
  int? creatorRequired;
  String? postExpiryDate;
  int? perCreatorAmount;
  int? userId;
  Setting? setting;
  double? totalAmount;

  AddPostModel({
    this.name,
    this.description,
    this.duration,
    this.deliverable,
    this.followersRequired,
    this.workMode,
    this.creatorRequired = 1,
    this.postExpiryDate,
    this.perCreatorAmount,
    this.userId,
    this.setting,
    this.totalAmount,
  });

  factory AddPostModel.fromRawJson(String str) =>
      AddPostModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AddPostModel.fromJson(Map<String, dynamic> json) => AddPostModel(
        name: json["name"],
        description: json["description"],
        duration: json["duration"],
        deliverable: json["deliverable"],
        followersRequired: json["followers_required"],
        workMode: json["work_mode"],
        creatorRequired: json["creator_required"],
        postExpiryDate: json["post_expiry_date"],
        perCreatorAmount: json["per_creator_amount"],
        userId: json["user_id"],
    totalAmount: json["total_amount"],
      );

  Map<dynamic, dynamic> toJson() => {
        "name": name,
        "description": description,
        "duration": duration,
        "deliverable": deliverable,
        "followers_required": followersRequired,
        "work_mode": workMode,
        "creator_required": creatorRequired,
        "post_expiry_date": postExpiryDate,
        "per_creator_amount": perCreatorAmount,
        "user_id": userId,
        "total_amount": totalAmount,
      };

  num getBudget() {
    num budget = perCreatorAmount! * creatorRequired!;
    return budget.abs().toDouble();
  }

  num getPlatformFees() {
    return (getBudget() * setting!.platformFeePercent!.abs()) / 100;
  }

  //27 - GSTNO starts from 27 then  totalGst = cGst + sGst; else use iGst
  num getTotalAppliedGst() {
    return (getBudget() * getTotalGst()) / 100;
  }

  num getTotalGst() {
    double totalGst = 0.0;
    if (setting!.gstNumber == null || setting!.gstNumber!.isEmpty ||  setting!.gstNumber!.startsWith('27')) {
      totalGst = setting!.cgstPercent!.abs() + setting!.sgstPercent!.abs();
    } else {
      totalGst = setting!.igstPercent!.abs();
    }
    return totalGst;
  }

  num calculateTotalAmount() {
    num budget = getBudget();
    double totalAmount = budget +
        (budget * (getTotalGst() + setting!.platformFeePercent!.abs()) / 100);
    this.totalAmount = totalAmount.abs();
    return totalAmount;
  }
}
