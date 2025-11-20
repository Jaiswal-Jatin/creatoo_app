import 'package:creatoo/core.dart';

import '../../auth/model/otp_reponse_model.dart';
import '../model/verify_otp_model.dart';

class VerifyOtpRepository {
  final BaseApiServices _apiServices = NetworkApiService();
  Map<String, String> headers = {'Content-Type': 'application/json'};

  Future<Either<AppException, VerifyOtpResponse>> verifyOtp(
      dynamic body) async {
    return await _apiServices.callPostAPI(
      roleId == Constants.creatorUser
          ? AppUrl.creatorLogin
          : AppUrl.businessLogin,
      headers,
      Parser.parseVerifyOtpResponse,
      body: body,
      disableTokenValidityCheck: true,
    );
  }

  Future<Either<AppException, OtpResponse>> resendOtp(body) async {
    return await _apiServices.callPostAPI(
      roleId == Constants.creatorUser
          ? AppUrl.resendCreatorOtp
          : AppUrl.resendBusinessOtp,
      headers,
      Parser.parseResendOtpResponse,
      body: body,
      disableTokenValidityCheck: true,
    );
  }
}
