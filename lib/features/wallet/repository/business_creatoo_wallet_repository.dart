import 'package:creatoo/core.dart';
import 'package:creatoo/features/wallet/model/business_wallet_transaction_point_response.dart';

class BusinessCreatooWalletRepository {
  final BaseApiServices _apiService = NetworkApiService();

  Future<Either<AppException, BusinessWalletTransactionPointResponse>> getBusinessTransactionPointApi(body) async {
    return await _apiService.callPostAPI(
      AppUrl.businessPointsTransaction,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseBusinessCreatooPointsReponse,
      body: body,
    );
  }
}
