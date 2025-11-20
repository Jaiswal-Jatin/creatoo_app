import 'package:creatoo/core.dart';
import 'package:creatoo/features/scanner/repository/scanner_repository.dart';

import '../model/business_list_response.dart';
import '../model/creatoo_points_response.dart';
import '../model/request_creatoo_points_model.dart';

class EarnCreatooPointsRepository extends ScannerRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, BusinessListResponse>> fetchBusinessListApi(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.getBusinessListApi,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseBusinessListResponse,
      body: body,
    );
  }

  Future<Either<AppException, CreatooPointsResponse>> requestCreatooPointsApi(RequestCreatooPointsModel body) async {
    return await _apiServices.callPostAPIForm(
      AppUrl.creatooRequestApi,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseCreatooPointsResponse,
      body: body.toJson(),
      imageFieldName: "image",
      path: body.image!,
    );
  }
}
