import 'dart:convert';
import 'package:creatoo/core.dart';
import 'package:creatoo/data/app_exceptions.dart';
import 'package:creatoo/data/network/base_api_services.dart';
import 'package:creatoo/data/network/network_api_service.dart';
import 'package:creatoo/resources/app_url.dart';
import '../model/manual_payment_model.dart';
import '../model/payment_stats_response.dart';

class BusinessPaymentsRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, ManualPaymentResponse>> getBusinessPayments({String? statusFilter}) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token ?? ""}',
      };
      final body = <String, dynamic>{};
      if (statusFilter != null) body['status'] = statusFilter;
      dynamic response = await _apiServices.callPostAPI<ManualPaymentResponse, ManualPaymentResponse>(
        AppUrl.manualBusinessPayments,
        headers,
        (response) => ManualPaymentResponse.fromJson(jsonDecode(response)),
        body: body,
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }

  Future<Either<AppException, Map<String, dynamic>>> confirmPayment(int paymentId) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token ?? ""}',
      };
      dynamic response = await _apiServices.callPostAPI<Map<String, dynamic>, Map<String, dynamic>>(
        AppUrl.manualConfirmPayment,
        headers,
        (response) => jsonDecode(response) as Map<String, dynamic>,
        body: {'payment_id': paymentId},
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }

  Future<Either<AppException, Map<String, dynamic>>> cancelPayment(int paymentId) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token ?? ""}',
      };
      dynamic response = await _apiServices.callPostAPI<Map<String, dynamic>, Map<String, dynamic>>(
        AppUrl.manualCancelPayment,
        headers,
        (response) => jsonDecode(response) as Map<String, dynamic>,
        body: {'payment_id': paymentId},
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }

  Future<Either<AppException, BusinessPaymentStatsResponse>> getPaymentStats() async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token ?? ""}',
      };
      dynamic response = await _apiServices.callPostAPI<BusinessPaymentStatsResponse, BusinessPaymentStatsResponse>(
        AppUrl.manualBusinessPaymentStats,
        headers,
        (response) => BusinessPaymentStatsResponse.fromJson(jsonDecode(response)),
        body: {},
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }

  Future<Either<AppException, Map<String, dynamic>>> getWalletPayments(String month) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token ?? ""}',
      };
      dynamic response = await _apiServices.callPostAPI<Map<String, dynamic>, Map<String, dynamic>>(
        AppUrl.manualBusinessWalletPayments,
        headers,
        (response) => jsonDecode(response) as Map<String, dynamic>,
        body: {'month': month},
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }
}
