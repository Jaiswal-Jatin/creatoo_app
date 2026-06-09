import 'dart:convert';
import 'package:creatoo/core.dart';
import 'package:creatoo/data/app_exceptions.dart';
import 'package:creatoo/data/network/base_api_services.dart';
import 'package:creatoo/data/network/network_api_service.dart';
import 'package:creatoo/resources/app_url.dart';
import '../model/business_visit_model.dart';

class BusinessVisitsRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, BusinessVisitsResponse>> getVisits({String? search, String? from, String? to}) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token ?? ""}',
      };
      String url = AppUrl.businessVisits;
      final params = <String, String>{};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (from != null) params['from'] = from;
      if (to != null) params['to'] = to;
      if (params.isNotEmpty) {
        url += '?' + params.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
      }
      dynamic response = await _apiServices.callGetAPI<BusinessVisitsResponse, BusinessVisitsResponse>(
        url,
        headers,
        (response) => BusinessVisitsResponse.fromJson(jsonDecode(response)),
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }
}
