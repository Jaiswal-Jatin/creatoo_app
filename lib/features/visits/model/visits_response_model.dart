class VisitsResponseModel {
  bool? status;
  String? message;
  Summary? summary;
  List<Day>? days;

  VisitsResponseModel({
    this.status,
    this.message,
    this.summary,
    this.days,
  });

  factory VisitsResponseModel.fromJson(Map<String, dynamic> json) => VisitsResponseModel(
        status: json["status"],
        message: json["message"],
        summary: json["summary"] == null ? null : Summary.fromJson(json["summary"]),
        days: json["days"] == null
            ? []
            : List<Day>.from(json["days"]!.map((x) => Day.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "summary": summary?.toJson(),
        "days": days == null ? [] : List<dynamic>.from(days!.map((x) => x.toJson())),
      };
}

class Summary {
  int? premium;
  int? elite;
  int? core;
  int? newVisitCount;

  Summary({
    this.premium,
    this.elite,
    this.core,
    this.newVisitCount,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        premium: json["premium"],
        elite: json["elite"],
        core: json["core"],
        newVisitCount: json["new"],
      );

  Map<String, dynamic> toJson() => {
        "premium": premium,
        "elite": elite,
        "core": core,
        "new": newVisitCount,
      };
}

class Day {
  final String date; // e.g. "2025-11-27"
  final List<Visit> visits;

  Day({required this.date, required this.visits});

  factory Day.fromJson(Map<String, dynamic> json) => Day(
        date: json["date"],
        visits: json["visits"] == null
            ? []
            : List<Visit>.from(json["visits"]!.map((x) => Visit.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "visits": List<dynamic>.from(visits.map((x) => x.toJson())),
      };
}

class Visit {
  final String userName;
  final DateTime dateTime;
  final Tier tier;
  final int? coins;

  Visit({
    required this.userName,
    required this.dateTime,
    required this.tier,
    this.coins,
  });

  factory Visit.fromJson(Map<String, dynamic> json) => Visit(
        userName: json["name"] as String? ?? 'N/A',
        dateTime: DateTime.parse(json["time"] as String? ?? DateTime.now().toIso8601String()),
        tier: _stringToTier(json["tier"] as String? ?? 'bronze'),
        coins: json["coins"] as int?,
      );

  Map<String, dynamic> toJson() => {
        "name": userName,
        "time": dateTime.toIso8601String(),
        "tier": tier.toString().split('.').last.toLowerCase(),
        "coins": coins,
      };

  static Tier _stringToTier(String? tierString) {
    switch (tierString?.toLowerCase()) {
      case 'gold':
      case 'premium':
        return Tier.premium;
      case 'silver':
      case 'elite':
        return Tier.elite;
      case 'bronze':
      case 'core':
        return Tier.core;
      case 'new':
      case 'newtier':
        return Tier.newTier;
      default:
        return Tier.core; // safe default
    }
  }
}

enum Tier { premium, newTier, elite, core }