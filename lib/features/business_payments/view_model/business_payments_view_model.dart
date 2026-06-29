import 'package:flutter/material.dart';
import 'package:creatoo/core.dart';
import 'package:creatoo/data/app_exceptions.dart';
import '../model/manual_payment_model.dart';
import '../model/payment_stats_response.dart';
import '../repository/business_payments_repository.dart';

class BusinessPaymentsViewModel extends ChangeNotifier {
  final BusinessPaymentsRepository _repo = BusinessPaymentsRepository();

  List<ManualPayment> _payments = [];
  List<ManualPayment> get payments => _payments;

  List<ManualPayment> get pendingPayments =>
      _payments.where((p) => p.status == 'PENDING').toList();

  List<ManualPayment> get confirmedPayments =>
      _payments.where((p) => p.status == 'CONFIRMED').toList();

  List<ManualPayment> get cancelledPayments =>
      _payments.where((p) => p.status == 'CANCELLED').toList();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _selectedFilter = 'ALL';
  String get selectedFilter => _selectedFilter;

  double _dailyTotal = 0;
  double get dailyTotal => _dailyTotal;

  double _monthlyTotal = 0;
  double get monthlyTotal => _monthlyTotal;

  List<ManualPayment> _recentPayments = [];
  List<ManualPayment> get recentPayments => _recentPayments;

  bool _isWalletLoading = false;
  bool get isWalletLoading => _isWalletLoading;

  List<ManualPayment> _walletPayments = [];
  List<ManualPayment> get walletPayments => _walletPayments;

  double _walletMonthlyTotal = 0;
  double get walletMonthlyTotal => _walletMonthlyTotal;

  Future<void> loadPayments({String? statusFilter}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final result = await _repo.getBusinessPayments(statusFilter: statusFilter);
    result.fold((error) {
      _error = error.message;
    }, (response) {
      _payments = response.data;
    });
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPaymentStats() async {
    _error = null;
    final result = await _repo.getPaymentStats();
    result.fold((error) {
      _error = error.message;
    }, (response) {
      if (response.data != null) {
        _dailyTotal = response.data!.dailyTotal;
        _monthlyTotal = response.data!.monthlyTotal;
        _recentPayments = response.data!.recentPayments;
      }
    });
    notifyListeners();
  }

  Future<void> fetchWalletPayments(String month) async {
    _isWalletLoading = true;
    notifyListeners();
    final result = await _repo.getWalletPayments(month);
    result.fold((error) {
      _error = error.message;
    }, (response) {
      final data = response['data'] as Map<String, dynamic>?;
      if (data != null) {
        _walletMonthlyTotal = (data['monthly_total'] ?? 0).toDouble();
        _walletPayments = (data['payments'] as List<dynamic>?)
                ?.map((e) => ManualPayment.fromJson(e))
                .toList() ??
            [];
      }
    });
    _isWalletLoading = false;
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }
}
