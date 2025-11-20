import 'dart:convert';

class RegisterCreator {
  String? name;
  String? mobile;
  String? email;
  String? address;
  String? instagramLink;
  String? instagramUsername;
  String? userImage;
  int? roleId;

  RegisterCreator({
    this.name,
    this.mobile,
    this.email,
    this.address,
    this.instagramLink,
    this.instagramUsername,
    this.userImage,
    this.roleId,
  });

  factory RegisterCreator.fromRawJson(String str) =>
      RegisterCreator.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RegisterCreator.fromJson(Map<String, dynamic> json) =>
      RegisterCreator(
        name: json["name"],
        mobile: json["mobile"],
        email: json["email"],
        address: json["address"],
        instagramLink: json["instagram_link"],
        instagramUsername: json["instagram_username"],
        userImage: json["user_image"],
        roleId: json["role_id"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "mobile": mobile,
        "email": email,
        "address": address,
        "instagram_link": instagramLink,
        "instagram_username": instagramUsername,
        "user_image": userImage,
        "role_id": roleId,
      };
}
