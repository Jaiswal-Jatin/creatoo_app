class VisitCheckResponse {
  bool? status;
  String? message;
  VisitCard? card;
  String? tier;
  List<VisitHistoryItem>? visitHistory;

  VisitCheckResponse({this.status, this.message, this.card, this.tier, this.visitHistory});

  factory VisitCheckResponse.fromJson(Map<String, dynamic> json) => VisitCheckResponse(
        status: json["status"],
        message: json["message"]?.toString(),
        card: json["card"] == null ? null : VisitCard.fromJson(json["card"]),
        tier: json["tier"],
        visitHistory: json["visit_history"] == null
            ? []
            : List<VisitHistoryItem>.from(json["visit_history"].map((x) => VisitHistoryItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "card": card?.toJson(),
        "tier": tier,
        "visit_history": visitHistory == null ? [] : List<dynamic>.from(visitHistory!.map((x) => x.toJson())),
      };
}

class VisitCard {
  dynamic cardNumber;
  String? name;
  dynamic userId;
  String? userImage;

  VisitCard({this.cardNumber, this.name, this.userId, this.userImage});

  factory VisitCard.fromJson(Map<String, dynamic> json) => VisitCard(
        cardNumber: json["card_number"],
        name: json["name"],
        userId: json["user_id"],
        userImage: json["user_image"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "card_number": cardNumber,
        "name": name,
        "user_id": userId,
        "user_image": userImage,
      };
}

class VisitHistoryItem {
  int? id;
  dynamic userId;
  dynamic cardNumber;
  dynamic businessId;
  String? businessName;
  String? businessImage;
  String? tier;
  String? time;
  String? userImage;
  String? userName;

  VisitHistoryItem({this.id, this.userId, this.cardNumber, this.businessId, this.businessName, this.businessImage, this.tier, this.time, this.userImage, this.userName});

  factory VisitHistoryItem.fromJson(Map<String, dynamic> json) => VisitHistoryItem(
        id: json["id"],
        userId: json["user_id"],
        cardNumber: json["card_number"],
        businessId: json["business_id"],
        businessName: json["business_name"]?.toString(),
        businessImage: json["business_image"]?.toString(),
        tier: json["tier"],
        time: json["time"],
        userImage: json["user_image"]?.toString(),
        userName: json["user_name"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "card_number": cardNumber,
        "business_id": businessId,
        "business_name": businessName,
        "business_image": businessImage,
        "tier": tier,
        "time": time,
        "user_image": userImage,
        "user_name": userName,
      };
}
