import 'package:creatoo/core.dart';
import 'package:flutter/foundation.dart';

import '../model/otp_reponse_model.dart';

class AuthRepository {
  final BaseApiServices _apiServices = NetworkApiService();
  Map<String, String> headers = {'Content-Type': 'application/json'};

  Future<Either<AppException, OtpResponse>> getOtp(dynamic data) async {
    final String apiUrl = roleId == Constants.creatorUser
          ? AppUrl.creatorLogin
          : AppUrl.businessLogin;

    debugPrint('Calling API: $apiUrl with body: $data');

    final result = await _apiServices.callPostAPI<OtpResponse, OtpResponse>(
      apiUrl,
      headers,
      Parser.parseLogInResponse,
      body: data,
      disableTokenValidityCheck: true,
    );

    result.fold(
      (error) => debugPrint('API Error for $apiUrl: $error'),
      (response) => debugPrint('API Response for $apiUrl: $response'),
    );

    return result;
  }
}
