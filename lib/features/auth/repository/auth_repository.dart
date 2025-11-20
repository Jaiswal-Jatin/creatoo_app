import 'package:creatoo/core.dart';

import '../model/otp_reponse_model.dart';

class AuthRepository {
  final BaseApiServices _apiServices = NetworkApiService();
  Map<String, String> headers = {'Content-Type': 'application/json'};

  Future<Either<AppException, OtpResponse>> getOtp(dynamic data) async {
    return await _apiServices.callPostAPI(
      roleId == Constants.creatorUser
          ? AppUrl.creatorLogin
          : AppUrl.businessLogin,
      headers,
      Parser.parseLogInResponse,
      body: data,
      disableTokenValidityCheck: true,
    );
  }
}
