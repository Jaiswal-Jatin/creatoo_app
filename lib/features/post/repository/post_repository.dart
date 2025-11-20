import '../../../core.dart';
import '../model/release_payment_to_creator.dart';
import '../model/view_my_post_response.dart';

class PostRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, ViewMyPostResponse>> getMyPostApi(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.viewMyPost,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseViewMyPostResponse,
      body: body,
    );
  }

  Future<Either<AppException, ReleasePaymentToCreatorResponse>>
      releasePaymentToCreatorApi(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.releasePaymentToCreatorApi,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseReleasePaymentToCreatorResponse,
      body: body,
    );
  }
}
