import 'package:creatoo/core.dart';

import '../../payment_details/model/payment_detail_response.dart';
import '../model/business_wallet_transaction_response.dart';
import '../repository/business_earning_wallet_repository.dart';

class BusinessWalletEarningViewModel with ChangeNotifier{
  final _repo= BusinessEarningWalletRepository();
  PaymentDetail? paymentDetail;
  bool isLoading = false;

  int walletBalance = 0;

  TextEditingController amountController = TextEditingController();
  ApiResponse<BusinessWalletTransactionResponse> transactionResponse =
  ApiResponse.completed(BusinessWalletTransactionResponse ());

  setResponse(ApiResponse<BusinessWalletTransactionResponse> response) {
    transactionResponse = response;
  }
/*
  ApiResponse<BusinessWithdrawBalanceResponse> withdrawResponse =
  ApiResponse.initial();

  setWithdrawResponse(ApiResponse<CreatorWithdrawBalanceResponse> response) {
    withdrawResponse = response;
  }

  init() async {
    walletBalance = 0;
    amountController = TextEditingController();
    await Future.wait([
      fetchBusinessWalletTransaction(),
      fetchPaymentDetails(),
    ]);
  }

  Future<void> fetchBusinessWalletTransaction() async {
    setResponse(ApiResponse.loading());
    var data = {"user_id": userId, "role_id": roleId};
    var response = await _repo.fetchBusinessWalletTransactionApi(data);
    response.fold(
          (l) {
        setResponse(ApiResponse.error(l.message));
        // Utils.toastMessage(l.message);
      },
          (r) {
        setResponse(ApiResponse.completed(r));
        // Utils.toastMessage(r.message!);
        walletBalance = r.data!.walletAmount ?? 0;
      },
    );
    notifyListeners();
  }


  Future<void> withdrawBalance() async {
    setWithdrawResponse(ApiResponse.loading());
    notifyListeners();
    var data = {
      "business_id": userId,
      "amount": int.parse(amountController.text)
    };
    amountController.clear();
    var response = await _repo.businessWithdrawRequestApi(data);
    response.fold(
          (l) {
        setWithdrawResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message);
      },
          (r) async {
        setWithdrawResponse(ApiResponse.completed(r));
        Utils.toastMessage(r.message!);
        await fetchBusinessWalletTransaction();
      },
    );
    notifyListeners();
  }

  Future<void> fetchPaymentDetails() async {
    isLoading = true;
    var response = await _repo.fetchPaymentDetailsApi();
    response.fold(
          (l) {
        Utils.toastMessage(l.message.toString());
      },
          (r) async {
        paymentDetail = r.data;
      },
    );
    isLoading = false;
    notifyListeners();
  }
  */


}