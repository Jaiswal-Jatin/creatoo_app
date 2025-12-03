import 'package:creatoo/features/search/model/business_details_response_model.dart';
import 'package:creatoo/features/search/model/exclusive_offers_response_model.dart';

import '../../../core.dart';
import '../model/search_business_model.dart';
import '../model/search_creator_model.dart';

class SearchRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, SearchBusinessResponse>> searchBusinessUserApi(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.searchUser,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseSearchBusinessResponse,
      body: body,
    );
  }

  Future<Either<AppException, SearchBusinessResponse>> searchBusinessUserByNameApi(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.searchBusinessAndCreator,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseSearchBusinessResponse,
      body: body,
    );
  }

  Future<Either<AppException, SearchCreatorResponse>> searchCreatorUserApi(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.searchUser,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseSearchCreatorResponse,
      body: body,
    );
  }

  // Future<Either<AppException, SearchCreatorResponse>> searchCreatorUserByNameApi(body) async {
  //   return await _apiServices.callPostAPI(
  //     AppUrl.searchBusinessAndCreator,
  //     {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
  //     Parser.parseSearchCreatorResponse,
  //     body: body,
  //   );
  // }

  Future<Either<AppException, BusinessDetailsResponseModel>> getBusinessDetails(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.viewProfile,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseGetBusinessDetailsResponse,
      body: body,
    );
  }

  Future<Either<AppException, ExclusiveOffersResponseModel>> getExclusiveOffers(int businessId) async {
    final apiUrl = AppUrl.getExclusiveOffers.replaceFirst(':id', businessId.toString());
    return await _apiServices.callGetAPI(
      apiUrl,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseExclusiveOffersResponse,
    );
  }

  Future<Either<AppException, SearchBusinessResponse>> fetchBusinessListApi(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.getBusinessListApi,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseSearchBusinessResponse, // Assuming it returns a similar structure
      body: body,
    );
  }
}
