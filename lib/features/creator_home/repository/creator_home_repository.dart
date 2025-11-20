import '../../../core.dart';
import '../../creator_profile/repository/creator_profile_repository.dart';
import '../model/creator_home_response_model.dart';

class CreatorHomeRepository extends CreatorProfileRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, CreatorHomeResponse>> getHomeDataApi(
      dynamic body) async {
    return await _apiServices.callPostAPI(
      AppUrl.creatorHomeApi,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseCreatorHomeResponse,
      body: body,
    );
  }
}
