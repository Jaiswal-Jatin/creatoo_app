import 'package:creatoo/features/creator_profile/model/creator_profile_response.dart';
import 'package:creatoo/features/register_creator/model/register_creator_model.dart';

import '../../../core.dart';
import '../model/insta_verification_response.dart';

class CreatorProfileRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, CreatorProfileResponse>> fetchCreatorProfileApi(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.viewProfile,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseCreatorProfileResponse,
      body: body,
    );
  }

  Future<Either<AppException, CreatorProfileResponse>> updateCreatorProfileApi(RegisterCreator body) async {
    if (body.userImage != null && body.userImage!.isNotEmpty) {
      return await _apiServices.callPostAPIForm(
        AppUrl.editCreatorProfile,
        {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        Parser.parseUpdateCreatorProfileResponse,
        body: body.toJson(),
        path: body.userImage ?? "",
        imageFieldName: "user_image",
      );
    } else {
      return await _apiServices.callPostAPI(
        AppUrl.editCreatorProfile,
        {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        Parser.parseUpdateCreatorProfileResponse,
        body: body.toJson(),
      );
    }
  }

  Future<Either<AppException, InstaVerificationResponse>> submitInstagramVerificationApi(dynamic body, String imagePath) async {
    return await _apiServices.callPostAPIForm(
      AppUrl.instaVerificationApi,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseInstaVerificationResponse,
      body: body,
      path: imagePath,
      imageFieldName: "profile_image",
    );
  }
}
