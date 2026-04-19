import 'dart:convert';

// Mocking the _toInt and _toString helpers from the original file

String? _toString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

class Review {
  int? experience;
  int? expectation;
  int? recommend;
  int? fairMoney;
  int? interaction;
  String? reviewText;

  Review({
    this.experience,
    this.expectation,
    this.recommend,
    this.fairMoney,
    this.interaction,
    this.reviewText,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        experience: json["experience"],
        expectation: json["expectation"],
        recommend: json["recommend"],
        fairMoney: json["fair_money"],
        interaction: json["interaction"],
        reviewText: json["review_text"],
      );

  Map<String, dynamic> toJson() => {
        "experience": experience,
        "expectation": expectation,
        "recommend": recommend,
        "fair_money": fairMoney,
        "interaction": interaction,
        "review_text": reviewText,
      };
}

class AverageRatings {
  String? avgExperience;
  String? avgExpectation;
  String? avgInteraction;
  String? avgRecommend;
  String? avgFairMoney;

  AverageRatings({
    this.avgExperience,
    this.avgExpectation,
    this.avgInteraction,
    this.avgRecommend,
    this.avgFairMoney,
  });

  factory AverageRatings.fromJson(Map<String, dynamic> json) => AverageRatings(
        avgExperience: _toString(json["avg_experience"]),
        avgExpectation: _toString(json["avg_expectation"]),
        avgInteraction: _toString(json["avg_interaction"]),
        avgRecommend: _toString(json["avg_recommend"]),
        avgFairMoney: _toString(json["avg_fair_money"]),
      );

  Map<String, dynamic> toJson() => {
        "avg_experience": avgExperience,
        "avg_expectation": avgExpectation,
        "avg_interaction": avgInteraction,
        "avg_recommend": avgRecommend,
        "avg_fair_money": avgFairMoney,
      };
}

class BusinessDescription {
  AverageRatings? averageRatings;
  List<Review>? reviews;

  BusinessDescription({this.averageRatings, this.reviews});

  factory BusinessDescription.fromJson(Map<String, dynamic> json) {
    var reviewsList = json["reviews"] == null
        ? <Review>[]
        : List<Review>.from(json["reviews"]!.map((x) => Review.fromJson(x)));

    var avgRatings = json["average_ratings"] == null
        ? AverageRatings()
        : AverageRatings.fromJson(json["average_ratings"]);

    if (reviewsList.isNotEmpty) {
      if (avgRatings.avgExperience == null || avgRatings.avgExperience == "0") {
        double total = reviewsList.fold(
            0, (sum, item) => sum + (item.experience?.toDouble() ?? 0));
        avgRatings.avgExperience =
            (total / reviewsList.length).toStringAsFixed(1);
      }
      if (avgRatings.avgExpectation == null ||
          avgRatings.avgExpectation == "0") {
        double total = reviewsList.fold(
            0, (sum, item) => sum + (item.expectation?.toDouble() ?? 0));
        avgRatings.avgExpectation =
            (total / reviewsList.length).toStringAsFixed(1);
      }
      if (avgRatings.avgInteraction == null ||
          avgRatings.avgInteraction == "0") {
        double total = reviewsList.fold(
            0, (sum, item) => sum + (item.interaction?.toDouble() ?? 0));
        avgRatings.avgInteraction =
            (total / reviewsList.length).toStringAsFixed(1);
      }
      if (avgRatings.avgRecommend == null || avgRatings.avgRecommend == "0") {
        double total = reviewsList.fold(
            0, (sum, item) => sum + (item.recommend?.toDouble() ?? 0));
        avgRatings.avgRecommend =
            "${((total / reviewsList.length) * 100).toStringAsFixed(0)}%";
      }
      if (avgRatings.avgFairMoney == null || avgRatings.avgFairMoney == "0") {
        double total = reviewsList.fold(
            0, (sum, item) => sum + (item.fairMoney?.toDouble() ?? 0));
        avgRatings.avgFairMoney =
            "${((total / reviewsList.length) * 100).toStringAsFixed(0)}%";
      }
    }

    return BusinessDescription(
        averageRatings: avgRatings, reviews: reviewsList);
  }
}

void main() {
  final jsonStr = '''{
    "average_ratings": {
        "avg_experience": 4.8
    },
    "reviews": [
        {
            "experience": 5,
            "expectation": 5,
            "recommend": 1,
            "fair_money": 1,
            "interaction": 5,
            "review_text": "good"
        },
        {
            "experience": 4,
            "expectation": 4,
            "recommend": 0,
            "fair_money": 0,
            "interaction": 4,
            "review_text": "ok"
        }
    ]
  }''';

  final data = json.decode(jsonStr);
  final business = BusinessDescription.fromJson(data);

  print('Average Experience: \${business.averageRatings?.avgExperience}');
  print('Average Expectation: \${business.averageRatings?.avgExpectation}');
  print('Average Interaction: \${business.averageRatings?.avgInteraction}');
  print('Average Recommend: \${business.averageRatings?.avgRecommend}');
  print('Average Fair Money: \${business.averageRatings?.avgFairMoney}');

  if (business.averageRatings?.avgExpectation == "4.5" &&
      business.averageRatings?.avgInteraction == "4.5" &&
      business.averageRatings?.avgRecommend == "50%" &&
      business.averageRatings?.avgFairMoney == "50%") {
    print('SUCCESS: Calculations are correct!');
  } else {
    print('FAILURE: Calculations are incorrect.');
  }
}
