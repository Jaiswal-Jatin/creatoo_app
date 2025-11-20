import 'package:creatoo/core.dart';
import 'package:creatoo/features/opportunity/model/report_response.dart';

import '../model/opportunity_response_model.dart';

class OpportunityRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, OpportunityResponse>> fetchOpportunitiesApi(
      dynamic body) {
    return _apiServices.callPostAPI(
      AppUrl.getPostOpportunitiesApi,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parsePostApplicationsResponse,
      body: body,
    );
  }

  Future<Either<AppException, ReportResponse>> postReportRequestApi(
      dynamic body) {
    return _apiServices.callPostAPI(
      AppUrl.postReportRequestApi,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseReportResponse,
      body: body,
    );
  }
}
