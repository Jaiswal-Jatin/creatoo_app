import 'dart:convert';

import 'package:creatoo/core.dart';

import '../../auth/model/otp_reponse_model.dart';
import '../model/verify_otp_model.dart';

class VerifyOtpRepository {
  final BaseApiServices _apiServices = NetworkApiService();
  Map<String, String> headers = {'Content-Type': 'application/json'};

  Future<Either<AppException, VerifyOtpResponse>> verifyOtp(
      dynamic body) async {
    final Map<String, dynamic> bodyMap = (body is Map<String, dynamic>) ? Map.from(body) : {};
    final Map<String, dynamic> cleaned = {};
    bodyMap.forEach((k, v) {
      if (v == null) return;
      if (k == 'mobile' || k == 'business_mobile' || k == 'otp' || k == 'device_id' || k == 'remember_token') {
        cleaned[k] = v.toString();
      } else {
        cleaned[k] = v;
      }
    });

    final String apiUrl = roleId == Constants.creatorUser ? AppUrl.verifyCreatorOtp : AppUrl.verifyBusinessOtp;
    debugPrint('Calling API: $apiUrl with body: ${jsonEncode(cleaned)}');

    return await _apiServices.callPostAPI(
      apiUrl,
      headers,
      Parser.parseVerifyOtpResponse,
      body: cleaned,
      disableTokenValidityCheck: true,
    );
  }

  Future<Either<AppException, OtpResponse>> resendOtp(body) async {
    final Map<String, dynamic> bodyMap = (body is Map<String, dynamic>) ? Map.from(body) : {};
    final Map<String, dynamic> cleaned = {};
    bodyMap.forEach((k, v) {
      if (v == null) return;
      if (k == 'mobile' || k == 'business_mobile' || k == 'otp' || k == 'device_id' || k == 'remember_token') {
        cleaned[k] = v.toString();
      } else {
        cleaned[k] = v;
      }
    });

    final String apiUrl = roleId == Constants.creatorUser ? AppUrl.resendCreatorOtp : AppUrl.resendBusinessOtp;
    debugPrint('Calling API: $apiUrl with body: ${jsonEncode(cleaned)}');

    return await _apiServices.callPostAPI(
      apiUrl,
      headers,
      Parser.parseResendOtpResponse,
      body: cleaned,
      disableTokenValidityCheck: true,
    );
  }
}
