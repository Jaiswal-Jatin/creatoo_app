import 'dart:convert';

class ReviewsResponseModel {
  bool? status;
  String? message;
  List<ReviewsData>? data;

  ReviewsResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory ReviewsResponseModel.fromRawJson(String str) => ReviewsResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ReviewsResponseModel.fromJson(Map<String, dynamic> json) => ReviewsResponseModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<ReviewsData>.from(json["data"]!.map((x) => ReviewsData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class ReviewsData {
  int? business_id;
  String? businessName;
  String? businessImage;
  double? experience;
  String? reviewText;
  int? daysAgo;

  ReviewsData({
    this.business_id,
    this.businessName,
    this.businessImage,
    this.experience,
    this.reviewText,
    this.daysAgo,
  });

  factory ReviewsData.fromRawJson(String str) => ReviewsData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ReviewsData.fromJson(Map<String, dynamic> json) => ReviewsData(
        business_id: json["business_id"],
        businessName: json["business_name"],
        businessImage: json["business_image"],
        experience: json["experience"]?.toDouble(),
        reviewText: json["review_text"],
        daysAgo: json["days_ago"],
      );

  Map<String, dynamic> toJson() => {
        "business_id": business_id,
        "business_name": businessName,
        "business_image": businessImage,
        "experience": experience,
        "review_text": reviewText,
        "days_ago": daysAgo,
      };
}
