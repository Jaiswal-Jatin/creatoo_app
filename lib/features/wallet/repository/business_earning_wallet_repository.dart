import 'package:creatoo/core.dart';
import 'package:creatoo/features/payment_details/model/payment_detail_response.dart';
import 'package:creatoo/features/payment_details/repository/payment_detail_repository.dart';

import '../model/business_wallet_transaction_response.dart';

class BusinessEarningWalletRepository extends PaymentDetailRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, BusinessWalletTransactionResponse>> fetchBusinessWalletTransactionsApi(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.businessWalletTransaction,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseBusinessWalletTransactionsResponse,
      body: body,
    );
  }

  Future<Either<AppException, PaymentDetailResponse>> fetchPaymentDetailsApi() async {
    return await _apiServices.callPostAPI(
      AppUrl.getPaymentDetailApi,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parsePaymentDetailResponse,
      body: {"user_id": userId},
    );
  }
}