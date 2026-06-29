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

  num _businessPoints = 0;
  num get businessPoints => _businessPoints;

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

  RazorpayOrderResponse? _razorpayOrder;
  RazorpayOrderResponse? get razorpayOrder => _razorpayOrder;

  Future<bool> createRazorpayOrder({
    required int businessId,
    required double billAmount,
    int pointsRedeemed = 0,
    double pointsValue = 0,
    required double finalAmount,
    int? discountPercentage,
    double? discountAmount,
    double? totalAmount,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final result = await _repo.createRazorpayOrder(
      businessId: businessId,
      billAmount: billAmount,
      pointsRedeemed: pointsRedeemed,
      pointsValue: pointsValue,
      finalAmount: finalAmount,
      discountPercentage: discountPercentage,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
    );
    final success = result.fold((error) {
      _error = error.message;
      return false;
    }, (order) {
      _razorpayOrder = order;
      return true;
    });
    _isLoading = false;
    notifyListeners();
    return success;
  }

  int _lastPointsEarned = 0;
  int get lastPointsEarned => _lastPointsEarned;

  Future<bool> submitPayment({
    required int businessId,
    required double billAmount,
    int pointsRedeemed = 0,
    double pointsValue = 0,
    required double finalAmount,
    int? discountPercentage,
    double? discountAmount,
    double platformFee = 0,
    double gstPercent = 0,
    double gstAmount = 0,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
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
      platformFee: platformFee,
      gstPercent: gstPercent,
      gstAmount: gstAmount,
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      razorpaySignature: razorpaySignature,
    );
    final success = result.fold((error) {
      _error = error.message;
      return false;
    }, (response) {
      _lastPointsEarned = (response['points_earned'] as num?)?.toInt() ?? 0;
      return response['status'] == true;
    });
    _isLoading = false;
    notifyListeners();
    if (success) await loadPayments();
    return success;
  }

  void clearCalculation() {
    _calculation = null;
    _razorpayOrder = null;
    notifyListeners();
  }
}
