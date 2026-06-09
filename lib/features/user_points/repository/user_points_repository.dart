import 'dart:convert';
import 'package:creatoo/core.dart';
import 'package:creatoo/data/network/base_api_services.dart';
import 'package:creatoo/data/network/network_api_service.dart';
import 'package:creatoo/resources/app_url.dart';
import 'package:creatoo/features/creator_wallet/model/creator_creatoo_transaction_response.dart';

class UserPointsRepository {
  final BaseApiServices _api = NetworkApiService();

  Future<Either<AppException, CreatorCreatooPointTransactionResponse>> fetchPointsTransactions() async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token ?? ""}',
      };
      final result = await _api.callPostAPI<Map<String, dynamic>, Map<String, dynamic>>(
        AppUrl.creatooPointsTransactionApi,
        headers,
        (response) => jsonDecode(response) as Map<String, dynamic>,
        body: {"user_id": "$userId"},
      );
      return result.fold(
        (error) => Left(error),
        (response) {
          final parsed = CreatorCreatooPointTransactionResponse.fromJson(response);
          return Right(parsed);
        },
      );
    } catch (e) {
      return Left(AppException(0, "Failed to load points: $e"));
    }
  }
}
