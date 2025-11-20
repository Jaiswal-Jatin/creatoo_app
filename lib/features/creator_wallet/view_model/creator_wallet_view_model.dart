import '../../../core.dart';
import '../../payment_details/model/payment_detail_response.dart';
import '../model/creator_creatoo_transaction_response.dart';
import '../model/creator_wallet_response.dart';
import '../model/creator_withdraw_balance_response.dart';
import '../repository/creator_wallet_repository.dart';

class CreatorWalletViewModel with ChangeNotifier {
  final _repo = CreatorWalletRepository();
  PaymentDetail? paymentDetail;
  bool isLoading = false;
  List<BusinessTransaction>? businessTransactions;
  TextEditingController searchController = TextEditingController();
  Map<int, bool> expandedStates = {};

  num creatooWalletBalance = 0;
  num earningWalletBalance = 0;
  TextEditingController amountController = TextEditingController();

  int currentSelection = 0;

  // int get currentSelection => currentSelection;

  // void changeIndex(int index) {
  //   currentSelection = index;
  //   notifyListeners();
  // }
  void notify() {
    notifyListeners();
  }

  void changeIndex(int index) {
    currentSelection = index;
    notifyListeners();
  }

  ApiResponse<CreatorWalletTransactionResponse> earningTransactionResponse = ApiResponse.initial();

  setEarningResponse(ApiResponse<CreatorWalletTransactionResponse> response) {
    earningTransactionResponse = response;
  }

  ApiResponse<CreatorWithdrawBalanceResponse> withdrawResponse = ApiResponse.initial();

  setWithdrawResponse(ApiResponse<CreatorWithdrawBalanceResponse> response) {
    withdrawResponse = response;
  }

  ApiResponse<CreatorCreatooPointTransactionResponse> creatooTransactionResponse = ApiResponse.initial();

  setCreatooResponse(ApiResponse<CreatorCreatooPointTransactionResponse> response) {
    creatooTransactionResponse = response;
  }

  double roundToTwoDecimalPlaces(double value) {
    return (value * 100).round() / 100;
  }

  void changeExpandedStates(bool expanded, int index) {
    expandedStates[index] = expanded;
    notifyListeners();
  }

  init() async {
    creatooWalletBalance = 0;
    earningWalletBalance = 0;
    amountController = TextEditingController();
    await fetchCreatorEarningWalletTransaction();
  }

  Future<void> fetchCreatorEarningWalletTransaction() async {
    setEarningResponse(ApiResponse.loading());
    var data = {"user_id": userId, "role_id": roleId, "search": searchController.text, "token": token};
    var response = await _repo.fetchCreatorWalletTransactionApi(data);
    response.fold(
      (l) {
        setEarningResponse(ApiResponse.error(l.message));
        // Utils.toastMessage(l.message);
      },
      (r) {
        setEarningResponse(ApiResponse.completed(r));
        // Utils.toastMessage(r.message!);
        earningWalletBalance = r.data!.walletAmount ?? 0;
      },
    );
    notifyListeners();
  }

  Future<void> withdrawBalance() async {
    setWithdrawResponse(ApiResponse.loading());
    notifyListeners();
    var data = {"creator_id": userId, "amount": int.parse(amountController.text)};
    amountController.clear();
    var response = await _repo.creatorWithdrawRequestApi(data);
    response.fold(
      (l) {
        setWithdrawResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message);
      },
      (r) async {
        setWithdrawResponse(ApiResponse.completed(r));
        Utils.toastMessage(r.message!);
        await fetchCreatorEarningWalletTransaction();
      },
    );
    notifyListeners();
  }

  Future<void> fetchCreatorCreatooWalletTransaction() async {
    creatooWalletBalance = 0;
    setCreatooResponse(ApiResponse.loading());
    // notifyListeners();
    var data = {"user_id": '$userId'};
    var response = await _repo.fetchCreatooPointsTransactionApi(data);
    response.fold(
      (l) {
        setCreatooResponse(ApiResponse.error(l.message));
        // Utils.toastMessage(l.message);
      },
      (r) {
        setCreatooResponse(ApiResponse.completed(r));
        // Utils.toastMessage(r.message!);
        creatooWalletBalance = r.data!.creatooPoints ?? 0;
        businessTransactions = r.data?.businessTransactions;
      },
    );
    notifyListeners();
  }
}
