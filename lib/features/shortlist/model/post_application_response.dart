import 'dart:convert';

class PostApplicationResponse {
  bool? status;
  String? message;
  List<Datum>? data;

  PostApplicationResponse({
    this.status,
    this.message,
    this.data,
  });

  factory PostApplicationResponse.fromRawJson(String str) =>
      PostApplicationResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PostApplicationResponse.fromJson(Map<String, dynamic> json) =>
      PostApplicationResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  int? id;
  String? name;
  String? email;
  String? mobile;
  int? roleId;
  String? instagramLink;
  String? bio;
  dynamic emailVerifiedAt;
  String? address;
  String? userImage;
  String? instagramUsername;
  int? isCart;
  int? isShortlist;
  double? engagementRate;

  Datum({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.roleId,
    this.instagramLink,
    this.bio,
    this.emailVerifiedAt,
    this.address,
    this.userImage,
    this.instagramUsername,
    this.isCart,
    this.isShortlist,
    this.engagementRate,
  });

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        mobile: json["mobile"],
        roleId: json["role_id"],
        instagramLink: json["instagram_link"],
        bio: json["bio"],
        emailVerifiedAt: json["email_verified_at"],
        address: json["address"],
        userImage: json["user_image"],
        instagramUsername: json["instagram_username"],
        isCart: json["is_cart"],
        isShortlist: json["is_shortlist"],
        engagementRate: json["engagement_rate"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "mobile": mobile,
        "role_id": roleId,
        "instagram_link": instagramLink,
        "bio": bio,
        "email_verified_at": emailVerifiedAt,
        "address": address,
        "user_image": userImage,
        "instagram_username": instagramUsername,
        "is_cart": isCart,
        "is_shortlist": isShortlist,
        "engagement_rate": engagementRate,
      };
}
