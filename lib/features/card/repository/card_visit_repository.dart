import 'dart:convert';
import 'dart:developer';
import 'package:creatoo/core.dart';
import 'package:creatoo/features/card/data/visit_by_restaurant_response_model.dart';

class CardVisitRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, VisitByRestaurantResponseModel>>
      getVisitByRestaurant(String token) async {
    try {
      log("CardVisitRepository: Fetching visit by restaurant data");
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      dynamic response =
          await _apiServices.callGetAPI<VisitByRestaurantResponseModel,
              VisitByRestaurantResponseModel>(
        AppUrl.visitByRestaurant,
        headers,
        (response) =>
            VisitByRestaurantResponseModel.fromJson(jsonDecode(response)),
      );
      return response;
    } on AppException catch (e) {
      log("CardVisitRepository: AppException - ${e.message}");
      return Left(e);
    } catch (e) {
      log("CardVisitRepository: Exception - $e");
      return Left(AppException(0, e.toString()));
    }
  }
}
