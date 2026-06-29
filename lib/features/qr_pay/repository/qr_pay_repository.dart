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

  Future<Either<AppException, Map<String, dynamic>>> getBusinessByUpiIdApi({required String upiId}) async {
    return await _apiServices.callPostAPI(
      AppUrl.getBusinessByUpiId,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      (response) => jsonDecode(response) as Map<String, dynamic>,
      body: {'upi_id': upiId},
    );
  }

  Future<Either<AppException, Map<String, dynamic>>> getBusinessBonusInfo({
    required Map<String, dynamic> body,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token ?? ""}',
      };
      final result = await _apiServices.callPostAPI<Map<String, dynamic>, Map<String, dynamic>>(
        AppUrl.getBusinessBonusInfoApi,
        headers,
        (response) => jsonDecode(response) as Map<String, dynamic>,
        body: body,
      );
      return result.fold(
        (error) => Left(error),
        (response) => Right(response),
      );
    } catch (e) {
      return Left(AppException(0, "Failed to get bonus info: $e"));
    }
  }
}
