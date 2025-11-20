import 'package:creatoo/core.dart';

import '../model/post_application_response.dart';

class ShortlistRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, PostApplicationResponse>> getPostApplicationListApi(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.getPostApplicationList,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parsePostApplicationListResponse,
      body: body,
    );
  }

  Future<Either<AppException, BaseResponse>> addCreatorToCartApi(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.addCreatorToCart,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseAddCreatorToCartResponse,
      body: body,
    );
  }

  Future<Either<AppException, PostApplicationResponse>> shortlistCreatorForPostApi(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.shortlistCreator,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parsePostApplicationListResponse,
      body: body,
    );
  }
}
