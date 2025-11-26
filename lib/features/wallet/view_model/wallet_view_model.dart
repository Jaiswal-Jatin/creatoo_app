import 'package:creatoo/core.dart';
import 'package:creatoo/features/wallet/repository/wallet_repository.dart';
import 'package:intl/intl.dart';

import '../model/business_wallet_transaction_response.dart';

class WalletViewModel with ChangeNotifier {
  final WalletRepository _myRepo = WalletRepository();
  TextEditingController searchController = TextEditingController();
  String? walletBalance;
  DateTime? fromDate = DateTime.now();
  DateTime? toDate = DateTime.now();

  ApiResponse<BusinessWalletTransactionResponse> walletResponse = ApiResponse.loading();

  setResponse(ApiResponse<BusinessWalletTransactionResponse> response) {
    walletResponse = response;
  }

  init() async {
    walletBalance = "0";
    await fetchBusinessWalletTransactions();
  }

  Future<void> fetchBusinessWalletTransactions() async {
    setResponse(ApiResponse.loading());
    notifyListeners();
    var data = {
      "user_id": userId,
      "search": searchController.text,
      "from_date": fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate!) : null,
      "to_date": toDate != null ? DateFormat('yyyy-MM-dd').format(toDate!) : null
    };
    var response = await _myRepo.fetchBusinessWalletTransactionsApi(data);
    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        walletBalance = (r.data?.businessWallet ?? 0) > 0 ? (r.data?.businessWallet.toString() ?? "0") : "0";
        setResponse(ApiResponse.completed(r));
        // Utils.toastMessage(r.message.toString());
      },
    );
    notifyListeners();
  }
}
