import 'dart:convert';

class CardCheckResponseModel {
  bool? status;
  String? message;
  CardData? data;

  CardCheckResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory CardCheckResponseModel.fromRawJson(String str) =>
      CardCheckResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CardCheckResponseModel.fromJson(Map<String, dynamic> json) {
    // Check if the response has a 'card' field (from the API response)
    final hasCard = json['hasCard'] == true;
    final cardData = hasCard && json['card'] != null 
        ? CardData.fromJson(json['card'])
        : null;
        
    return CardCheckResponseModel(
      status: json["status"],
      message: json["message"],
      data: cardData,
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class CardData {
  int? id;
  String? userId;
  String? cardNumber;
  String? status;
  String? name;
  String? createdAt;
  String? updatedAt;

  CardData({
    this.id,
    dynamic userId,
    this.cardNumber,
    dynamic status,
    this.name,
    this.createdAt,
    this.updatedAt,
  }) : 
    userId = userId is int ? userId.toString() : (userId is String ? userId : null),
    status = status is int ? (status == 1 ? 'active' : 'inactive') : (status is String ? status : 'inactive');

  factory CardData.fromJson(Map<String, dynamic> json) => CardData(
        id: json["id"],
        userId: json["user_id"] ?? json["userId"],
        cardNumber: (json["card_number"] ?? json["cardNumber"])?.toString(),
        status: json["status"],
        name: json["name"],
        createdAt: json["created_at"] ?? json["createdAt"],
        updatedAt: json["updated_at"] ?? json["updatedAt"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "card_number": cardNumber,
        "status": status,
        "name": name,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
