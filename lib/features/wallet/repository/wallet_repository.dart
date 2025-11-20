import 'package:creatoo/core.dart';

import '../model/business_wallet_transaction_response.dart';

class WalletRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, BusinessWalletTransactionResponse>> fetchBusinessWalletTransactionsApi(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.businessWalletTransaction,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseBusinessWalletTransactionsResponse,
      body: body,
    );
  }
}
