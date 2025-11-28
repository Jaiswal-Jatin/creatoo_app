import 'dart:convert';

/// Helper function to safely convert dynamic values to String
String? _toString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

class VisitByRestaurantResponseModel {
  final bool? status;
  final List<RestaurantVisitData>? restaurants;

  VisitByRestaurantResponseModel({
    this.status,
    this.restaurants,
  });

  factory VisitByRestaurantResponseModel.fromRawJson(String str) =>
      VisitByRestaurantResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory VisitByRestaurantResponseModel.fromJson(Map<String, dynamic> json) =>
      VisitByRestaurantResponseModel(
        status: json["status"] as bool?,
        restaurants: json["restaurants"] == null
            ? []
            : List<RestaurantVisitData>.from(
                json["restaurants"].map((x) => RestaurantVisitData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "restaurants": restaurants == null
            ? []
            : List<dynamic>.from(restaurants!.map((x) => x.toJson())),
      };
}

class RestaurantVisitData {
  final int? businessId;
  final String? businessName;
  final String? businessImage;
  final int? totalVisits;
  final List<RestaurantVisit>? visits;

  RestaurantVisitData({
    this.businessId,
    this.businessName,
    this.businessImage,
    this.totalVisits,
    this.visits,
  });

  factory RestaurantVisitData.fromRawJson(String str) =>
      RestaurantVisitData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RestaurantVisitData.fromJson(Map<String, dynamic> json) =>
      RestaurantVisitData(
        businessId: json["business_id"] as int?,
        businessName: json["business_name"] as String?,
        businessImage: json["business_image"] as String?,
        totalVisits: json["total_visits"] as int?,
        visits: json["visits"] == null
            ? []
            : List<RestaurantVisit>.from(
                json["visits"].map((x) => RestaurantVisit.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "business_id": businessId,
        "business_name": businessName,
        "business_image": businessImage,
        "total_visits": totalVisits,
        "visits": visits == null
            ? []
            : List<dynamic>.from(visits!.map((x) => x.toJson())),
      };
}

class RestaurantVisit {
  final int? id;
  final int? userId;
  final String? cardNumber;
  final int? businessId;
  final String? tier;
  final String? time;

  RestaurantVisit({
    this.id,
    this.userId,
    this.cardNumber,
    this.businessId,
    this.tier,
    this.time,
  });

  factory RestaurantVisit.fromRawJson(String str) =>
      RestaurantVisit.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RestaurantVisit.fromJson(Map<String, dynamic> json) =>
      RestaurantVisit(
        id: json["id"] as int?,
        userId: json["user_id"] as int?,
        cardNumber: _toString(json["card_number"]),
        businessId: json["business_id"] as int?,
        tier: json["tier"] as String?,
        time: json["time"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "card_number": cardNumber,
        "business_id": businessId,
        "tier": tier,
        "time": time,
      };
}
