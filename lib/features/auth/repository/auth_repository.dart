import 'dart:convert';

import 'package:creatoo/core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../model/otp_reponse_model.dart';

class AuthRepository {
  final BaseApiServices _apiServices = NetworkApiService();
  Map<String, String> headers = {'Content-Type': 'application/json'};

  Future<Either<AppException, OtpResponse>> getOtp(dynamic data) async {
    // Decide endpoint based on payload to avoid roleId timing issues.
    final Map<String, dynamic> bodyMap = (data is Map<String, dynamic>) ? Map.from(data) : {};
    final String apiUrl = bodyMap.containsKey('business_mobile')
        ? AppUrl.businessLogin
        : AppUrl.creatorLogin;

    // Clean and normalize body: convert mobile/otp/device_id/remember_token to strings and drop nulls
    final Map<String, dynamic> cleaned = {};
    bodyMap.forEach((k, v) {
      if (v == null) return;
      if (k == 'mobile' || k == 'business_mobile' || k == 'otp' || k == 'device_id' || k == 'remember_token') {
        cleaned[k] = v.toString();
      } else {
        cleaned[k] = v;
      }
    });

    debugPrint('Calling API: $apiUrl with body: ${jsonEncode(cleaned)}');
    // If this is a business login, use a direct HTTP client to match exact Postman behavior
    if (cleaned.containsKey('business_mobile')) {
      return await _businessLogin(cleaned);
    }

    final result = await _apiServices.callPostAPI<OtpResponse, OtpResponse>(
      apiUrl,
      headers,
      Parser.parseLogInResponse,
      body: cleaned,
      disableTokenValidityCheck: true,
    );

    result.fold(
      (error) => debugPrint('API Error for $apiUrl: $error'),
      (response) => debugPrint('API Response for $apiUrl: $response'),
    );

    return result;
  }

  Future<Either<AppException, OtpResponse>> _businessLogin(Map<String, dynamic> cleaned) async {
    final String url = AppUrl.businessLogin;
    final headersLocal = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Accept-Encoding': 'identity',
      'Connection': 'keep-alive',
      'User-Agent': 'Dart/2.18 (dart:io)',
    };

    final bodyJson = jsonEncode(cleaned);

    if (kDebugMode) {
      debugPrint('Sending businessLogin to: $url');
      debugPrint('Headers: ${jsonEncode(headersLocal)}');
      debugPrint('Body: $bodyJson');
    }

    try {
      final client = http.Client();
      try {
        final response = await client.post(Uri.parse(url), headers: headersLocal, body: bodyJson);
        if (kDebugMode) {
          debugPrint('Response status: ${response.statusCode}');
          debugPrint('Response body: ${response.body}');
        }

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          return Right(OtpResponse.fromJson(jsonResponse));
        } else {
          final jsonResponse = response.body.isNotEmpty ? jsonDecode(response.body) : null;
          final message = jsonResponse != null && jsonResponse['message'] != null ? jsonResponse['message'] : response.body;
          return Left(ServerError(statusCode: response.statusCode, message: message));
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Exception in businessLogin: $e');
      return Left(UnknownError(message: e.toString()));
    }
  }
}
