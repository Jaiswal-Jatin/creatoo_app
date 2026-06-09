import 'package:flutter/material.dart';
import 'package:creatoo/core.dart';
import 'package:creatoo/features/creator_wallet/model/creator_creatoo_transaction_response.dart';
import '../../business_payments/model/manual_payment_model.dart';
import '../../user_points/repository/user_points_repository.dart';
import '../repository/user_payments_repository.dart';

class UserPaymentsViewModel extends ChangeNotifier {
  final UserPaymentsRepository _repo = UserPaymentsRepository();
  final UserPointsRepository _pointsRepo = UserPointsRepository();

  List<ManualPayment> _payments = [];
  List<ManualPayment> get payments => _payments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int _businessPoints = 0;
  int get businessPoints => _businessPoints;

  int _todayVisitCount = 0;
  int get todayVisitCount => _todayVisitCount;

  String _todayVisitTier = 'new';
  String get todayVisitTier => _todayVisitTier;

  PaymentCalculation? _calculation;
  PaymentCalculation? get calculation => _calculation;

  Future<void> loadPayments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final result = await _repo.getPayments();
    result.fold((error) {
      _error = error.message;
    }, (response) {
      _payments = response.data;
    });
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTodayVisitCount(int businessId) async {
    final result = await _repo.getTodayVisitCount(businessId);
    result.fold((_) {}, (response) {
      _todayVisitCount = response.todayCount;
      _todayVisitTier = response.tier;
      notifyListeners();
    });
  }

  Future<void> loadBusinessPoints(int businessId) async {
    final result = await _pointsRepo.fetchPointsTransactions();
    result.fold((_) {}, (response) {
      final txns = response.data?.businessTransactions ?? [];
      final match = txns.cast<BusinessTransaction?>().firstWhere(
        (t) => t?.businessId == businessId,
        orElse: () => null,
      );
      _businessPoints = match?.totalPoints ?? 0;
      notifyListeners();
    });
  }

  Future<bool> calculatePayment({
    required int businessId,
    required double billAmount,
    int pointsRedeemed = 0,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final result = await _repo.calculatePayment(
      businessId: businessId,
      billAmount: billAmount,
      pointsRedeemed: pointsRedeemed,
    );
    final success = result.fold((error) {
      _error = error.message;
      return false;
    }, (calc) {
      _calculation = calc;
      return true;
    });
    _isLoading = false;
    notifyListeners();
    return success;
  }

  int? _lastPaymentId;
  int? get lastPaymentId => _lastPaymentId;

  Future<bool> submitPayment({
    required int businessId,
    required double billAmount,
    int pointsRedeemed = 0,
    double pointsValue = 0,
    required double finalAmount,
    int? discountPercentage,
    double? discountAmount,
  }) async {
    _isLoading = true;
    notifyListeners();
    final result = await _repo.submitPayment(
      businessId: businessId,
      billAmount: billAmount,
      pointsRedeemed: pointsRedeemed,
      pointsValue: pointsValue,
      finalAmount: finalAmount,
      discountPercentage: discountPercentage,
      discountAmount: discountAmount,
    );
    final success = result.fold((error) {
      _error = error.message;
      return false;
    }, (response) {
      if (response['status'] == true && response['data'] != null) {
        _lastPaymentId = response['data']['id'] as int?;
      }
      return response['status'] == true;
    });
    _isLoading = false;
    notifyListeners();
    if (success) await loadPayments();
    return success;
  }

  Future<bool> setPaymentPaidAt(int paymentId) async {
    final result = await _repo.setPaymentPaidAt(paymentId: paymentId);
    return result.fold((error) {
      _error = error.message;
      return false;
    }, (response) {
      return response['status'] == true;
    });
  }

  void clearCalculation() {
    _calculation = null;
    notifyListeners();
  }
}
