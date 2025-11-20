import 'dart:convert';

class UserInstaResponse {
  bool? status;
  String? message;
  UserInsta? data;

  UserInstaResponse({
    this.status,
    this.message,
    this.data,
  });

  factory UserInstaResponse.fromRawJson(String str) =>
      UserInstaResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserInstaResponse.fromJson(Map<String, dynamic> json) =>
      UserInstaResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : UserInsta.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class UserInsta {
  String? username;
  String? fullName;
  String? profilePicUrl;

  UserInsta({
    this.username,
    this.fullName,
    this.profilePicUrl,
  });

  factory UserInsta.fromRawJson(String str) =>
      UserInsta.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserInsta.fromJson(Map<String, dynamic> json) => UserInsta(
        username: json["username"],
        fullName: json["full_name"],
        profilePicUrl: json["profile_pic_url"],
      );

  Map<String, dynamic> toJson() => {
        "username": username,
        "full_name": fullName,
        "profile_pic_url": profilePicUrl,
      };
}
