import 'dart:convert';

class ActivateCardResponseModel {
  bool? status;
  String? message;
  int? cardNumber;
  int? userId;
  String? name;

  ActivateCardResponseModel({
    this.status,
    this.message,
    this.cardNumber,
    this.userId,
    this.name,
  });

  factory ActivateCardResponseModel.fromRawJson(String str) =>
      ActivateCardResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ActivateCardResponseModel.fromJson(Map<String, dynamic> json) =>
      ActivateCardResponseModel(
        status: json["status"],
        message: json["message"],
        cardNumber: json["card_number"],
        userId: json["user_id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "card_number": cardNumber,
        "user_id": userId,
        "name": name,
      };
}
