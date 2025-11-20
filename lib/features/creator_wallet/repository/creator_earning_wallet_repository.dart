import 'package:creatoo/core.dart';
import 'package:creatoo/features/payment_details/repository/payment_detail_repository.dart';

import '../model/creator_wallet_response.dart';
import '../model/creator_withdraw_balance_response.dart';

class CreatorEarningWalletRepository extends PaymentDetailRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, CreatorWalletTransactionResponse>>
      fetchCreatorWalletTransactionApi(dynamic body) async {
    return await _apiServices.callPostAPI(
      AppUrl.creatorWalletTransaction,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseCreatorWalletTransactionResponse,
      body: body,
    );
  }

  Future<Either<AppException, CreatorWithdrawBalanceResponse>>
      creatorWithdrawRequestApi(dynamic body) async {
    return await _apiServices.callPostAPI(
      AppUrl.creatorWithdrawRequestApi,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseCreatorWithdrawBalanceResponse,
      body: body,
    );
  }
}
