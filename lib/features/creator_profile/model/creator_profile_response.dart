import 'dart:convert';

class CreatorProfileResponse {
  bool? status;
  String? message;
  Data? data;

  CreatorProfileResponse({
    this.status,
    this.message,
    this.data,
  });

  factory CreatorProfileResponse.fromRawJson(String str) =>
      CreatorProfileResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CreatorProfileResponse.fromJson(Map<String, dynamic> json) =>
      CreatorProfileResponse(
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
  int? id;
  String? name;
  String? email;
  String? mobile;
  String? address;
  String? instagramLink;
  String? instagramUsername;
  String? userImage;
  int? isActive;
  int? roleId;
  String? instagramFullname;
  int? followerCount;
  int? followingCount;
  int? mediaCount;
  String? bio;
  double? engagementRate;
  double? avgActivity;
  double avgActivityPercentage;
  dynamic avgLikes;
  dynamic avgComments;
  DateTime? updatedAt;
  int? instagramVerificationStatus;
  String? verificationNote;

  Data({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.address,
    this.instagramLink,
    this.instagramUsername,
    this.userImage,
    this.isActive,
    this.roleId,
    this.instagramFullname,
    this.followerCount,
    this.followingCount,
    this.mediaCount,
    this.bio,
    this.engagementRate,
    this.avgActivity,
    this.avgLikes,
    this.avgComments,
    this.updatedAt,
    this.avgActivityPercentage = 0.0,
    this.instagramVerificationStatus,
    this.verificationNote,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        mobile: json["mobile"],
        address: json["address"],
        instagramLink: json["instagram_link"],
        instagramUsername: json["instagram_username"],
        userImage: json["user_image"],
        isActive: json["is_active"],
        roleId: json["role_id"],
        instagramFullname: json["instagram_fullname"],
        followerCount: json["follower_count"],
        followingCount: json["following_count"],
        mediaCount: json["media_count"],
        bio: json["bio"],
        engagementRate: json["engagement_rate"]?.toDouble(),
        avgActivity: json["avg_activity"]?.toDouble(),
        avgLikes: json["avg_likes"],
        avgComments: json["avg_comments"],
        verificationNote: json["verification_note"],
        instagramVerificationStatus: json["is_insta_verified"] == null
            ? 3
            : int.parse(json["is_insta_verified"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "mobile": mobile,
        "address": address,
        "instagram_link": instagramLink,
        "instagram_username": instagramUsername,
        "user_image": userImage,
        "is_active": isActive,
        "role_id": roleId,
        "instagram_fullname": instagramFullname,
        "follower_count": followerCount,
        "following_count": followingCount,
        "media_count": mediaCount,
        "bio": bio,
        "engagement_rate": engagementRate,
        "avg_activity": avgActivity,
        "avg_likes": avgLikes,
        "avg_comments": avgComments,
        "verification_note": verificationNote,
        "is_insta_verified": instagramVerificationStatus,
        "updated_at": updatedAt?.toIso8601String(),
      };

  double calculateAvgActivityPercentage() {
    avgActivityPercentage = 0.0;
    if (avgActivity == null) return avgActivityPercentage;
    avgActivityPercentage = (avgActivity! / 100);
    if (avgActivityPercentage >= 1.0) {
      return 1.0;
    }
    return avgActivityPercentage;
  }
}
