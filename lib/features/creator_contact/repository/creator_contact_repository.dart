import '../../../core.dart';
import '../model/creator_contact_response.dart';

class CreatorContactRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, CreatorContactResponse>> getCreatorContactApi(
      dynamic body) async {
    return await _apiServices.callPostAPI(
      AppUrl.creatorContactApi,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseCreatorContactResponse,
      body: body,
    );
  }
}
