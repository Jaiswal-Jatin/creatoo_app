import 'dart:convert';

class ShortlistModel {
  dynamic postId;
  String? token;
  List<String>? creatorIds;

  ShortlistModel({
    this.postId,
    this.token,
    this.creatorIds,
  });

  factory ShortlistModel.fromRawJson(String str) => ShortlistModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ShortlistModel.fromJson(Map<String, dynamic> json) => ShortlistModel(
    postId: json["post_id"],
    token: json["token"],
    creatorIds: json["creator_ids"] == null ? [] : List<String>.from(json["creator_ids"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "post_id": postId,
    "token": token,
    "creator_ids": creatorIds == null ? [] : List<dynamic>.from(creatorIds!.map((x) => x)),
  };
}
