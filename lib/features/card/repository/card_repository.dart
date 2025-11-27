import 'dart:convert';
import 'package:creatoo/core.dart';
import 'package:creatoo/data/app_exceptions.dart';
import 'package:creatoo/data/network/base_api_services.dart';
import 'package:creatoo/data/network/network_api_service.dart';
import 'package:creatoo/features/card/data/activate_card_request_model.dart';
import 'package:creatoo/features/card/data/activate_card_response_model.dart';
import 'package:creatoo/features/card/data/card_check_response_model.dart';
import 'package:creatoo/features/card/data/user_tier_history_response_model.dart';
import 'package:creatoo/resources/app_url.dart';

class CardRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, ActivateCardResponseModel>> activeCardApi(
      ActivateCardRequestModel requestBody) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token ?? ""}',
      };
      dynamic response = await _apiServices.callPostAPI<ActivateCardResponseModel, ActivateCardResponseModel>(
        AppUrl.activeCard,
        headers,
        (response) => ActivateCardResponseModel.fromJson(jsonDecode(response)),
        body: requestBody.toJson(),
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }

  Future<Either<AppException, CardCheckResponseModel>> checkCardApi() async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token ?? ""}',
      };
      
      dynamic response = await _apiServices.callGetAPI<CardCheckResponseModel, CardCheckResponseModel>(
        AppUrl.cardCheck,
        headers,
        (response) => CardCheckResponseModel.fromJson(jsonDecode(response)),
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }

  Future<Either<AppException, UserTierHistoryResponseModel>> getUserTierHistoryApi() async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token ?? ""}',
      };
      dynamic response = await _apiServices.callGetAPI<UserTierHistoryResponseModel, UserTierHistoryResponseModel>(
        AppUrl.userTierHistory,
        headers,
        (response) => UserTierHistoryResponseModel.fromJson(jsonDecode(response)),
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }
}
