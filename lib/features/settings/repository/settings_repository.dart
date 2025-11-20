import 'package:creatoo/features/business_profile/repository/business_profile_repository.dart';

import '../../../core.dart';
import '../model/logout_model.dart';

class SettingsRepository extends BusinessProfileRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, LogoutResponse>> logoutApi() async {
    return await _apiServices.callPostAPI(
      AppUrl.logout,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseLogoutResponse,
      body: {"token": token},
    );
  }

  Future<Either<AppException, LogoutResponse>> inactiveUserApi() async {
    return await _apiServices.callPostAPI(
      AppUrl.inactiveUser,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseInactiveUserResponse,
      body: {"token": token},
    );
  }
}
