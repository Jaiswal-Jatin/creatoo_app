import 'dart:developer';
import 'package:creatoo/data/response/api_response.dart';
import 'package:creatoo/features/visits/model/visits_response_model.dart';
import 'package:creatoo/features/visits/repository/visits_repository.dart';
import 'package:flutter/foundation.dart';

class VisitsViewModel with ChangeNotifier {
  final VisitsRepository _myRepo = VisitsRepository();

  ApiResponse<VisitsResponseModel> visitsResponse = ApiResponse.loading();

  void setVisitsResponse(ApiResponse<VisitsResponseModel> response) {
    visitsResponse = response;
    notifyListeners();
  }

  Future<void> fetchBusinessVisitsApi(String token) async {
    log("VisitsViewModel: Fetching business visits API called with token: $token");
    setVisitsResponse(ApiResponse.loading());
    _myRepo.fetchBusinessVisits(token).then((value) {
      log("VisitsViewModel: API response received: $value");
      value.fold(
        (error) {
          log("VisitsViewModel: API Error: ${error.message}");
          setVisitsResponse(ApiResponse.error(error.message.toString()));
        },
        (visitsModel) {
          log("VisitsViewModel: API Success, data: ${visitsModel.toJson()}");
          setVisitsResponse(ApiResponse.completed(visitsModel));
        },
      );
    }).onError((error, stackTrace) {
      log("VisitsViewModel: Unhandled Error: $error \n StackTrace: $stackTrace");
      setVisitsResponse(ApiResponse.error(error.toString()));
    });
  }
}
