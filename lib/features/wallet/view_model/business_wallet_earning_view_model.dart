import 'package:creatoo/core.dart';
import 'package:creatoo/features/payment_details/model/payment_detail_response.dart';
import 'package:creatoo/features/wallet/repository/business_earning_wallet_repository.dart';
import 'package:intl/intl.dart';

import '../model/business_wallet_transaction_response.dart';

class BusinessWalletEarningViewModel with ChangeNotifier {
  final BusinessEarningWalletRepository _myRepo =
      BusinessEarningWalletRepository();
  TextEditingController searchController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  double walletBalance = 0.0;
  DateTime? fromDate;
  DateTime? toDate;
  DateTime? selectedDate; // For calendar date selection
  PaymentDetail? paymentDetail;

  ApiResponse<BusinessWalletTransactionResponse> transactionResponse =
      ApiResponse.loading();

  setResponse(ApiResponse<BusinessWalletTransactionResponse> response) {
    transactionResponse = response;
  }

  init() async {
    walletBalance = 0.0;
    // By default select today's date for settlement display
    DateTime today = DateTime.now();
    selectedDate = DateTime(today.year, today.month, today.day);
    fromDate = selectedDate;
    toDate = selectedDate;
    await fetchBusinessWalletTransactions();
    await fetchPaymentDetails();
  }

  // Select a specific date from calendar
  void selectDate(DateTime date) {
    selectedDate = DateTime(date.year, date.month, date.day);
    fromDate = selectedDate;
    toDate = selectedDate;
    fetchBusinessWalletTransactions();
  }

  // Clear date filter
  void clearDateFilter() {
    selectedDate = null;
    fromDate = null;
    toDate = null;
    fetchBusinessWalletTransactions();
  }

  // Get all transactions grouped by date
  Map<DateTime, List<Transaction>> get groupedTransactions {
    if (transactionResponse.data?.transactions == null) return {};
    Map<DateTime, List<Transaction>> grouped = {};
    for (var transaction in transactionResponse.data!.transactions!) {
      if (transaction.created_at != null) {
        DateTime localCreatedAt = transaction.created_at!.toLocal();
        DateTime date = DateTime(
          localCreatedAt.year,
          localCreatedAt.month,
          localCreatedAt.day,
        );
        if (!grouped.containsKey(date)) {
          grouped[date] = [];
        }
        grouped[date]!.add(transaction);
      }
    }
    return grouped;
  }

  // Get settlement amount for a specific date
  double getSettlementForDate(DateTime date) {
    DateTime normalizedDate = DateTime(date.year, date.month, date.day);
    if (!groupedTransactions.containsKey(normalizedDate)) return 0.0;

    double total = 0.0;
    for (var transaction in groupedTransactions[normalizedDate]!) {
      total += transaction.settlementAmount ?? 0.0;
    }
    return total;
  }

  // Get all dates that have transactions
  Set<DateTime> get transactionDates {
    return groupedTransactions.keys.toSet();
  }

  Future<void> fetchBusinessWalletTransactions() async {
    setResponse(ApiResponse.loading());
    notifyListeners();
    var data = {
      "user_id": userId,
      "search": searchController.text,
      "from_date":
          fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate!) : null,
      "to_date":
          toDate != null ? DateFormat('yyyy-MM-dd').format(toDate!) : null
    };
    var response = await _myRepo.fetchBusinessWalletTransactionsApi(data);
    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        walletBalance = 0.0; // businessWallet not available in new structure
        setResponse(ApiResponse.completed(r));
      },
    );
    notifyListeners();
  }

  Future<void> fetchPaymentDetails() async {
    var response = await _myRepo.fetchPaymentDetailsApi();
    response.fold(
      (l) {
        // Error fetching payment details
        paymentDetail = null;
      },
      (r) async {
        paymentDetail = r.data;
      },
    );
    notifyListeners();
  }
}
