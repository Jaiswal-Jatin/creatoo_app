import 'dart:convert';

class CreatorContactResponse {
  final bool? status;
  final String? message;
  final List<CreatorContact>? data;

  CreatorContactResponse({
    this.status,
    this.message,
    this.data,
  });

  factory CreatorContactResponse.fromRawJson(String str) =>
      CreatorContactResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CreatorContactResponse.fromJson(Map<String, dynamic> json) =>
      CreatorContactResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<CreatorContact>.from(
                json["data"]!.map((x) => CreatorContact.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class CreatorContact {
  final String? name;
  final String? mobile;
  final String? email;
  final String? instagramUsername;
  final String? address;

  CreatorContact({
    this.name,
    this.mobile,
    this.email,
    this.instagramUsername,
    this.address,
  });

  factory CreatorContact.fromRawJson(String str) =>
      CreatorContact.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CreatorContact.fromJson(Map<String, dynamic> json) => CreatorContact(
        name: json["name"],
        mobile: json["mobile"],
        email: json["email"],
        instagramUsername: json["instagram_username"],
        address: json["address"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "mobile": mobile,
        "email": email,
        "instagram_username": instagramUsername,
        "address": address,
      };
}
