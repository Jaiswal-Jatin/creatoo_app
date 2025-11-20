import 'package:creatoo/core.dart';
import 'package:creatoo/features/register_creator/model/register_creator_model.dart';
import 'package:creatoo/features/register_creator/model/register_creator_response%20_model.dart';

import '../model/user_insta_response.dart';

class RegisterCreatorRepository {
  final BaseApiServices _apiServices = NetworkApiService();
  int? userType;

  initialiseUser() async {
    final SharedPreferencesService prefs = SharedPreferencesService();
    return userType = await prefs.getUserRoleId();
  }

  Future<Either<AppException, RegisterCreatorResponse>> registerCreator(RegisterCreator data) async {
    if (data.userImage != null) {
      return await _apiServices.callPostAPIForm(
        AppUrl.registerCreator,
        {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        Parser.parseRegisterCreatorResponse,
        body: data.toJson(),
        imageFieldName: "user_image",
        path: data.userImage!,
        disableTokenValidityCheck: true,
      );
    } else {
      return await _apiServices.callPostAPI(
        AppUrl.registerCreator,
        {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        Parser.parseRegisterCreatorResponse,
        body: data.toJson(),
        disableTokenValidityCheck: true,
      );
    }
  }

  Future<Either<AppException, UserInstaResponse>> fetchInstaUser(dynamic body) async {
    return await _apiServices.callPostAPI(
      AppUrl.fetchInstaUser,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseUserInstaResponse,
      body: body,
      disableTokenValidityCheck: true,
    );
  }
}
