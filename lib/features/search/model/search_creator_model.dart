class SearchCreatorResponse {
  bool? status;
  List<Data>? data;

  SearchCreatorResponse({this.status, this.data});

  SearchCreatorResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? email;
  String? mobile;
  String? instagramLink;
  String? instagramUsername;
  String? userImage;
  String? bio;
  int? isActive;
  int? roleId;
  int? instagramVerificationStatus;

  Data({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.instagramLink,
    this.instagramUsername,
    this.userImage,
    this.bio,
    this.isActive,
    this.roleId,
    this.instagramVerificationStatus,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    mobile = json['mobile'];
    instagramLink = json['instagram_link'];
    instagramUsername = json['instagram_username'];
    userImage = json['user_image'];
    bio = json['bio'];
    isActive = json['is_active'];
    roleId = json['role_id'];
    instagramVerificationStatus = json["is_insta_verified"] == null
        ? 3
        : int.parse(json["is_insta_verified"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['mobile'] = this.mobile;
    data['instagram_link'] = this.instagramLink;
    data['instagram_username'] = this.instagramUsername;
    data['user_image'] = this.userImage;
    data['bio'] = this.bio;
    data['is_active'] = this.isActive;
    data['role_id'] = this.roleId;
    data['is_insta_verified'] = this.instagramVerificationStatus;

    return data;
  }
}
