import 'dart:developer';
import 'package:creatoo/data/app_exceptions.dart';
import 'package:creatoo/data/network/base_api_services.dart';
import 'package:creatoo/data/network/network_api_service.dart';
import 'package:creatoo/data/response/parser.dart';
import 'package:creatoo/features/visits/model/visits_response_model.dart';
import 'package:creatoo/features/visits/model/visit_check_response_model.dart';
import 'package:creatoo/features/visits/model/add_visit_response_model.dart';
import 'package:creatoo/resources/app_url.dart';
import 'package:dartz/dartz.dart';

class VisitsRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, VisitsResponseModel>> fetchBusinessVisits(String token) async {
    try {
      log("VisitsRepository: Initiating fetchBusinessVisits API call");
      final response = await _apiServices.callGetAPI(
        AppUrl.busineesHistory,
        {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        Parser.parseVisitsResponseModel, // Assuming a parser function exists or will be created
      );
      log("VisitsRepository: API call completed with raw response: $response");

      // We expect the 'dynamic' value on the Right side to be a VisitsResponseModel
      // because Parser.parseVisitsResponseModel was used. We use .map to cast it.
      return response.map(
        (data) {
          // Safely cast the dynamic data to VisitsResponseModel.
          // This assumes Parser.parseVisitsResponseModel correctly produces a VisitsResponseModel.
          // If `data` is not actually a `VisitsResponseModel` at runtime, this will throw an error,
          // which will be caught by the outer `catch` block and wrapped in an `AppException`.
          return data as VisitsResponseModel;
        },
      );
    } on AppException catch (e) {
      log("VisitsRepository: AppException during fetchBusinessVisits API call", error: e);
      return Left(e);
    } catch (e) {
      log("VisitsRepository: Generic error during fetchBusinessVisits API call", error: e);
      return Left(AppException("Unknown Error" as int, e.toString()));
    }
  }

  Future<Either<AppException, VisitCheckResponse>> checkVisit(String cardNumber, String token) async {
    try {
      log("VisitsRepository: Initiating checkVisit API call for card: $cardNumber");
      final url = '${AppUrl.visitCheck}card_number=$cardNumber';
      final response = await _apiServices.callGetAPI(
        url,
        {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        Parser.parseVisitCheckResponse,
      );
      log("VisitsRepository: checkVisit raw response: $response");
      return response.map((data) => data as VisitCheckResponse);
    } on AppException catch (e) {
      log("VisitsRepository: AppException during checkVisit API call", error: e);
      return Left(e);
    } catch (e) {
      log("VisitsRepository: Generic error during checkVisit API call", error: e);
      return Left(AppException("Unknown Error" as int, e.toString()));
    }
  }

  Future<Either<AppException, AddVisitResponse>> addVisit(String cardNumber, String token) async {
    try {
      log("VisitsRepository: Initiating addVisit API call for card: $cardNumber");
      final requestBody = {"card_number": int.parse(cardNumber)};
      print("📤 ADDVISIT Request: $requestBody");
      log("VisitsRepository: addVisit request body: $requestBody");
      
      final response = await _apiServices.callPostAPI(
        AppUrl.Addvisit,
        {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        Parser.parseAddVisitResponse,
        body: requestBody,
      );
      
      // Response is an Either, so we need to handle it
      response.fold((error) {
        print("❌ ADDVISIT API Error: ${error.message}");
      }, (data) {
        print("✅ ADDVISIT Response: Status=${data.status}, Message=${data.message}");
      });
      
      log("VisitsRepository: addVisit response: $response");
      return response.map((data) => data as AddVisitResponse);
    } on AppException catch (e) {
      print("❌ ADDVISIT Error: ${e.message}");
      log("VisitsRepository: AppException during addVisit API call", error: e);
      return Left(e);
    } catch (e) {
      print("❌ ADDVISIT Exception: $e");
      log("VisitsRepository: Generic error during addVisit API call", error: e);
      return Left(AppException("Unknown Error" as int, e.toString()));
    }
  }
}
