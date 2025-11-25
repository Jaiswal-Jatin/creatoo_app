import 'dart:convert';

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is bool) return value ? 1 : 0;
  if (value is String) return int.tryParse(value);
  return null;
}

class RegisterCreatorResponse {
  bool? status;
  String? message;
  Data? data;

  RegisterCreatorResponse({
    this.status,
    this.message,
    this.data,
  });

  factory RegisterCreatorResponse.fromRawJson(String str) => RegisterCreatorResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RegisterCreatorResponse.fromJson(Map<String, dynamic> json) => RegisterCreatorResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  String? token;
  int? id;
  String? name;
  String? email;
  String? mobile;
  dynamic address;
  String? image;
  String? bio;
  String? instagramLink;
  String? instagramUsername;
  int? isActive;
  int? roleId;

  Data({
    this.token,
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.address,
    this.image,
    this.bio,
    this.instagramLink,
    this.instagramUsername,
    this.isActive,
    this.roleId,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    token: json["token"],
    id: json["id"],
    name: json["name"],
    email: json["email"],
    mobile: json["mobile"],
    address: json["address"],
    image: json["image"],
    bio: json["bio"],
    instagramLink: json["instagram_link"],
    instagramUsername: json["instagram_username"],
    isActive: _toInt(json["is_active"]),
    roleId: json["role_id"],
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "id": id,
    "name": name,
    "email": email,
    "mobile": mobile,
    "address": address,
    "image": image,
    "bio": bio,
    "instagram_link": instagramLink,
    "instagram_username": instagramUsername,
    "is_active": isActive,
    "role_id": roleId,
  };
}
