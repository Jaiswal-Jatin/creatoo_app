import 'dart:developer';
import 'package:creatoo/data/response/api_response.dart';
import 'package:creatoo/features/card/data/visit_by_restaurant_response_model.dart';
import 'package:creatoo/features/card/repository/card_visit_repository.dart';
import 'package:creatoo/features/card/widgets/visit_tab_view.dart';
import 'package:creatoo/utils/enums/status.dart';
import 'package:flutter/foundation.dart';

class CardVisitViewModel with ChangeNotifier {
  final CardVisitRepository _myRepo = CardVisitRepository();

  ApiResponse<VisitByRestaurantResponseModel> visitResponse =
      ApiResponse.initial();

  void setVisitResponse(
      ApiResponse<VisitByRestaurantResponseModel> response) {
    visitResponse = response;
    notifyListeners();
  }

  Future<void> fetchVisitByRestaurant(String token) async {
    try {
      log("CardVisitViewModel: Fetching visit by restaurant with token: $token");
      setVisitResponse(ApiResponse.loading());

      final result = await _myRepo.getVisitByRestaurant(token);

      result.fold(
        (error) {
          log("CardVisitViewModel: API Error - ${error.message}");
          setVisitResponse(ApiResponse.error(error.message));
        },
        (response) {
          log("CardVisitViewModel: API Success - ${response.toJson()}");
          if (response.status == true) {
            setVisitResponse(ApiResponse.completed(response));
          } else {
            setVisitResponse(
                ApiResponse.error('Failed to fetch visit data'));
          }
        },
      );
    } catch (e) {
      log("CardVisitViewModel: Exception - $e");
      setVisitResponse(ApiResponse.error(e.toString()));
    }
  }

  Visit? getMostRecentVisit() {
    if (visitResponse.status == Status.completed &&
        visitResponse.data != null) {
      final apiResponse = visitResponse.data!;
      List<Visit> allVisits = [];

      if (apiResponse.restaurants != null) {
        for (var restaurant in apiResponse.restaurants!) {
          if (restaurant.visits != null && restaurant.visits!.isNotEmpty) {
            for (var visit in restaurant.visits!) {
              allVisits.add(
                Visit(
                  restaurantName: restaurant.businessName ?? 'Unknown',
                  date: _parseDate(visit.time),
                  tier: visit.tier ?? 'new',
                  imageUrl: restaurant.businessImage ?? '',
                ),
              );
            }
          }
        }
      }

      if (allVisits.isEmpty) {
        return null;
      }

      // Sort all visits by date to find the most recent one
      allVisits.sort((a, b) => b.date.compareTo(a.date));

      return allVisits.first;
    }
    return null;
  }

  DateTime _parseDate(String? dateStr) {
    if (dateStr == null) return DateTime.now();
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }
}
