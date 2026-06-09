import 'package:creatoo/core.dart';
import '../model/settlement_response_model.dart';
import '../repository/settlement_repository.dart';

class SettlementViewModel with ChangeNotifier {
  final SettlementRepository _repo = SettlementRepository();

  // Summary
  WalletSummaryData? _summary;
  WalletSummaryData? get summary => _summary;

  bool _isLoadingSummary = false;
  bool get isLoadingSummary => _isLoadingSummary;

  // Transactions
  List<WalletTransactionItem> _transactions = [];
  List<WalletTransactionItem> get transactions => _transactions;

  // Advance payments
  List<WalletTransactionItem> _advancePayments = [];
  List<WalletTransactionItem> get advancePayments => _advancePayments;

  // Settlement history
  List<SettlementHistoryItem> _settlementHistory = [];
  List<SettlementHistoryItem> get settlementHistory => _settlementHistory;

  // Filter
  String _selectedFilter = 'lifetime';
  String get selectedFilter => _selectedFilter;

  void setFilter(String filter) {
    _selectedFilter = filter;
    if (filter != 'custom') {
      fetchSummary();
    }
    notifyListeners();
  }

  Future<void> fetchSummary() async {
    _isLoadingSummary = true;
    notifyListeners();

    String? filter;
    if (_selectedFilter != 'lifetime') {
      filter = _selectedFilter;
    }

    final result = await _repo.getWalletSummary(filter: filter);
    result.fold(
      (l) => _summary = null,
      (r) => _summary = r.data,
    );

    _isLoadingSummary = false;
    notifyListeners();
  }

  Future<void> fetchTransactions({String? status, String? source, String? fromDate, String? toDate}) async {
    final result = await _repo.getTransactions(
      status: status,
      source: source,
      fromDate: fromDate,
      toDate: toDate,
    );
    result.fold(
      (l) => _transactions = [],
      (r) => _transactions = r,
    );
    notifyListeners();
  }

  Future<void> fetchAdvancePayments() async {
    final result = await _repo.getAdvancePayments();
    result.fold(
      (l) => _advancePayments = [],
      (r) => _advancePayments = r,
    );
    notifyListeners();
  }

  Future<void> fetchSettlementHistory() async {
    final result = await _repo.getSettlementHistory();
    result.fold(
      (l) => _settlementHistory = [],
      (r) => _settlementHistory = r,
    );
    notifyListeners();
  }

  Future<void> init() async {
    await Future.wait([
      fetchSummary(),
      fetchAdvancePayments(),
      fetchSettlementHistory(),
    ]);
  }
}
