import 'package:creatoo/core.dart';
import 'package:creatoo/features/wallet/repository/wallet_repository.dart';

import '../model/business_wallet_transaction_response.dart';

class WalletViewModel with ChangeNotifier {
  final WalletRepository _myRepo = WalletRepository();
  TextEditingController searchController = TextEditingController();
  String? walletBalance;
  DateTime? fromDate;
  DateTime? toDate;
  DateTime? selectedDate; // Track selected start date for settlement display
  DateTime? selectedEndDate; // Track selected end date for date range

  ApiResponse<BusinessWalletTransactionResponse> walletResponse =
      ApiResponse.loading();

  setResponse(ApiResponse<BusinessWalletTransactionResponse> response) {
    walletResponse = response;
  }

  init() async {
    walletBalance = "0";
    // Set default to today's date
    DateTime today = DateTime.now();
    selectedDate = DateTime(today.year, today.month, today.day);
    selectedEndDate = selectedDate;
    // Fetch all transactions without date filter for calendar dots
    fromDate = null;
    toDate = null;
    await fetchBusinessWalletTransactions();
  }

  // Get all transactions grouped by date
  Map<DateTime, List<Transaction>> get groupedTransactions {
    if (walletResponse.data?.transactions == null) return {};
    Map<DateTime, List<Transaction>> grouped = {};
    for (var transaction in walletResponse.data!.transactions!) {
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

  // Get settlement amount for a date range
  double getSettlementForDateRange(DateTime startDate, DateTime endDate) {
    double total = 0.0;
    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    DateTime end = DateTime(endDate.year, endDate.month, endDate.day);

    while (!current.isAfter(end)) {
      total += getSettlementForDate(current);
      current = current.add(Duration(days: 1));
    }
    return total;
  }

  // Get transactions for a date range
  List<Transaction> getTransactionsForDateRange(
      DateTime startDate, DateTime endDate) {
    List<Transaction> transactions = [];
    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    DateTime end = DateTime(endDate.year, endDate.month, endDate.day);

    while (!current.isAfter(end)) {
      if (groupedTransactions.containsKey(current)) {
        transactions.addAll(groupedTransactions[current]!);
      }
      current = current.add(Duration(days: 1));
    }
    return transactions;
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
      // Always fetch all data, do not send from_date or to_date
    };
    var response = await _myRepo.fetchBusinessWalletTransactionsApi(data);
    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        walletBalance = "0"; // businessWallet not available in new structure
        setResponse(ApiResponse.completed(r));
        // Debug print to verify parsed transactions
        print('API Response: ${r.toRawJson()}');
        print('Parsed transactions: ${r.transactions}');
        print('Transaction count: ${r.transactions?.length}');
      },
    );
    notifyListeners();
  }
}
