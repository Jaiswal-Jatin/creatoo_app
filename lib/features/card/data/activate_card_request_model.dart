import 'dart:convert';

class ActivateCardRequestModel {
  String? name;
  String? number;

  ActivateCardRequestModel({
    this.name,
    this.number,
  });

  factory ActivateCardRequestModel.fromRawJson(String str) =>
      ActivateCardRequestModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ActivateCardRequestModel.fromJson(Map<String, dynamic> json) =>
      ActivateCardRequestModel(
        name: json["name"],
        number: json["number"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "number": number,
      };
}
