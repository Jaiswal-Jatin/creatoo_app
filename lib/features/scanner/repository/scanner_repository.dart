import '../../../core.dart';
import '../model/scanner_model_response.dart';

class ScannerRepository {
  final BaseApiServices _apiService = NetworkApiService();
  Future<Either<AppException, ScannerModelResponse>> getBusinessSettingApi(body) async {
    return await _apiService.callPostAPI(
      AppUrl.getBusinessSetting,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseBusinessSettingResponse,
      body: body,
    );
  }

  Future<Either<AppException, ScannerModelResponse>> updateBusinessSettingApi(body) async {
    return await _apiService.callPostAPI(
      AppUrl.businessSetting,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseBusinessSettingResponse,
      body: body,
    );
  }
}
