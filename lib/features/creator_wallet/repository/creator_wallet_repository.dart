import '../../../core.dart';
import '../../payment_details/repository/payment_detail_repository.dart';
import '../model/creator_creatoo_transaction_response.dart';
import '../model/creator_wallet_response.dart';
import '../model/creator_withdraw_balance_response.dart';

class CreatorWalletRepository extends PaymentDetailRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, CreatorWalletTransactionResponse>> fetchCreatorWalletTransactionApi(dynamic body) async {
    return await _apiServices.callPostAPI(
      AppUrl.creatorWalletTransaction,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseCreatorWalletTransactionResponse,
      body: body,
    );
  }

  Future<Either<AppException, CreatorWithdrawBalanceResponse>> creatorWithdrawRequestApi(dynamic body) async {
    return await _apiServices.callPostAPI(
      AppUrl.creatorWithdrawRequestApi,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseCreatorWithdrawBalanceResponse,
      body: body,
    );
  }

  Future<Either<AppException, CreatorCreatooPointTransactionResponse>> fetchCreatooPointsTransactionApi(dynamic body) async {
    return await _apiServices.callPostAPI(
      AppUrl.creatooPointsTransactionApi,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseCreatorCreatooPointTransactionResponse,
      body: body,
    );
  }
}
