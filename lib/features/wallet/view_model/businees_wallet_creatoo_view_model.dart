import '../../../core.dart';
import '../model/business_wallet_transaction_point_response.dart';
import '../repository/business_creatoo_wallet_repository.dart';

class BusinessWalletCreatooViewModel with ChangeNotifier {
  final BusinessCreatooWalletRepository _myRepo = BusinessCreatooWalletRepository();
  num? walletBalanceCreato;
  List<Transactions> transactions = []; // Add transactions list

  ApiResponse<BusinessWalletTransactionPointResponse> transactionCreatorResponse = ApiResponse.loading();

  setResponse(ApiResponse<BusinessWalletTransactionPointResponse> response) {
    transactionCreatorResponse = response;
  }

  init() async {
    walletBalanceCreato = 0;

    await getTransactionPointRange(DateTime.now(), DateTime.now());
  }

  double roundToTwoDecimalPlaces(double value) {
    return (value * 100).round() / 100;
  }

  Future<void> getTransactionPointRange(DateTime fromDate, DateTime toDate) async {
    setResponse(ApiResponse.loading());

    var data = {
      "business_id": userId,
      "from_date": _formatDate(fromDate),
      "to_date": _formatDate(toDate),
    };

    var response = await _myRepo.getBusinessTransactionPointApi(data);

    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        walletBalanceCreato = r.data!.userCreatooPoints ?? 0;
        if (walletBalanceCreato! < 0) {
          walletBalanceCreato = 0;
        }
        // Update transactions list with range data
        transactions = r.data?.transactions ?? [];
        setResponse(ApiResponse.completed(r));
      },
    );

    notifyListeners();
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
