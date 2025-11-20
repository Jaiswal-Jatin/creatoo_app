import '../../../core.dart';
import '../model/transfer_points_response_model.dart';
import '../model/validate_points_response_model.dart';
import '../model/view_profile_response_model.dart';

class QrPayRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, ViewProfileResponseModel>> getBusinessDataApi({required Map<String, dynamic> body}) async {
    return await _apiServices.callPostAPI(
      AppUrl.viewProfile,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseViewProfileResponse,
      body: body,
    );
  }

  Future<Either<AppException, ValidatePointsResponseModel>> validatePointsApi({required Map<String, dynamic> body}) async {
    return await _apiServices.callPostAPI(
      AppUrl.validatePointsApi,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseValidatePointsResponse,
      body: body,
    );
  }

  Future<Either<AppException, TransferPointsResponseModel>> transferPointsApi({required Map<String, dynamic> body}) async {
    return await _apiServices.callPostAPI(
      AppUrl.transferPointsApi,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseTransferPointsResponse,
      body: body,
    );
  }
}
