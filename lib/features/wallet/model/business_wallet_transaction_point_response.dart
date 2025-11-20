import 'dart:convert';

BusinessWalletTransactionPointResponse businessWalletTarnsactionPointResponseFromJson(String str) =>
    BusinessWalletTransactionPointResponse.fromJson(json.decode(str));

String businessWalletTransactionPointResponseToJson(BusinessWalletTransactionPointResponse data) => json.encode(data.toJson());

class BusinessWalletTransactionPointResponse {
  final bool? status;
  final String? message;
  final Data? data;

  BusinessWalletTransactionPointResponse({
    this.status,
    this.message,
    this.data,
  });

  BusinessWalletTransactionPointResponse copyWith({
    bool? status,
    String? message,
    Data? data,
  }) =>
      BusinessWalletTransactionPointResponse(
        status: status ?? this.status,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory BusinessWalletTransactionPointResponse.fromJson(Map<String, dynamic> json) => BusinessWalletTransactionPointResponse(
        status: json["status"],
        message: json["Message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "Message": message,
        "data": data?.toJson(),
      };
}

class Data {
  final num? userCreatooPoints;
  final List<Transactions>? transactions;

  Data({
    this.userCreatooPoints,
    this.transactions,
  });

  Data copyWith({
    num? userCreatooPoints,
    List<Transactions>? transactions,
  }) =>
      Data(
        userCreatooPoints: userCreatooPoints ?? this.userCreatooPoints,
        transactions: transactions ?? this.transactions,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        userCreatooPoints: json["user_creatoo_points"],
        transactions:
            json["transactions"] == null ? [] : List<Transactions>.from(json["transactions"]!.map((x) => Transactions.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "user_creatoo_points": userCreatooPoints,
        "transactions": transactions == null ? [] : List<dynamic>.from(transactions!.map((x) => x.toJson())),
      };
}

class Transactions {
  final int? id;
  final num? points;
  final String? status;
  final String? instagramUsername;
  final String? creatorName;
  final DateTime? createdAt;

  Transactions({
    this.id,
    this.points,
    this.status,
    this.instagramUsername,
    this.creatorName,
    this.createdAt,
  });

  Transactions copyWith({
    int? id,
    double? points,
    String? status,
    String? instagramUsername,
    String? creatorName,
    DateTime? createdAt,
  }) =>
      Transactions(
        id: id ?? this.id,
        points: points ?? this.points,
        status: status ?? this.status,
        instagramUsername: instagramUsername ?? this.instagramUsername,
        creatorName: creatorName ?? this.creatorName,
        createdAt: createdAt ?? this.createdAt,
      );

  factory Transactions.fromJson(Map<String, dynamic> json) => Transactions(
        id: json["id"],
        points: json["points"],
        status: json["status"],
        instagramUsername: json["instagram_username"],
        creatorName: json["creator_name"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "points": points,
        "status": status,
        "instagram_username": instagramUsername,
        "creator_name": creatorName,
        "created_at": createdAt?.toIso8601String(),
      };
}
