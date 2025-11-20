import 'package:creatoo/core.dart';

import '../model/post_detail_response.dart';

class PostDetailRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, BaseResponse>> addInterestToPostApi(dynamic body) async {
    return await _apiServices.callPostAPI(
      AppUrl.postInterestApi,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parsePostInterestResponse,
      body: body,
    );
  }

  Future<Either<AppException, PostDetailResponse>> getOpportunityApi(dynamic body) async {
    return await _apiServices.callPostAPI(
      AppUrl.opportunityDetailsApi,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parsePostDetailResponse,
      body: body,
    );
  }
}
