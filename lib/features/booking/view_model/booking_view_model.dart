import 'package:flutter/material.dart';
import 'package:creatoo/data/app_exceptions.dart';
import '../model/booking_model.dart';
import '../repository/booking_repository.dart';

class BookingViewModel extends ChangeNotifier {
  final BookingRepository _repo = BookingRepository();

  // ─── User Booking History ───
  List<BookingModel> _userBookings = [];
  List<BookingModel> get userBookings => _userBookings;

  // ─── Business Incoming Bookings ───
  List<BookingModel> _businessBookings = [];
  List<BookingModel> get businessBookings => _businessBookings;

  // ─── Loading & Error ───
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _error;
  String? get error => _error;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // ─── Advance Payment State ───
  bool _isCreatingAdvanceOrder = false;
  bool get isCreatingAdvanceOrder => _isCreatingAdvanceOrder;

  AdvanceOrderResponse? _currentAdvanceOrder;
  AdvanceOrderResponse? get currentAdvanceOrder => _currentAdvanceOrder;

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  // ─── Load User Booking History ───
  Future<void> loadUserHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repo.getUserHistory();
    result.fold(
      (err) => _error = err.message,
      (res) => _userBookings = res.data,
    );

    _isLoading = false;
    notifyListeners();
  }

  // ─── Load Business Incoming Bookings ───
  Future<void> loadBusinessBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repo.getBusinessList();
    result.fold(
      (err) => _error = err.message,
      (res) => _businessBookings = res.data,
    );

    _isLoading = false;
    notifyListeners();
  }

  // ─── Submit Booking Request ───
  Future<bool> submitBookingRequest({
    required int businessId,
    required String bookingDate,
    required String bookingTime,
    int? guestsCount,
    String? serviceName,
    String? sportName,
    String? notes,
  }) async {
    _isSubmitting = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    final body = <String, dynamic>{
      'business_id': businessId,
      'booking_date': bookingDate,
      'booking_time': bookingTime,
      if (guestsCount != null) 'guests_count': guestsCount,
      if (serviceName != null) 'service_name': serviceName,
      if (sportName != null) 'sport_name': sportName,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    final result = await _repo.createBookingRequest(body);
    bool success = false;

    result.fold(
      (err) => _error = err.message,
      (res) {
        if (res.status) {
          _successMessage = res.message;
          success = true;
        } else {
          _error = res.message;
        }
      },
    );

    _isSubmitting = false;
    notifyListeners();
    return success;
  }

  // ─── Accept / Reject Booking (Business side) ───
  /// [advanceAmount] = null or 0 means "accept without advance"
  Future<bool> updateBookingStatus({
    required int bookingId,
    required String status, // 'accepted' or 'rejected'
    String? rejectionReason,
    double? advanceAmount,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final body = <String, dynamic>{
      'booking_id': bookingId,
      'status': status,
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
      if (advanceAmount != null && advanceAmount > 0)
        'advance_amount': advanceAmount,
    };

    final result = await _repo.updateStatus(body);
    bool success = false;

    result.fold(
      (err) => _error = err.message,
      (res) {
        if (res.status) {
          success = true;
          // Reload the bookings to reflect new state
          loadBusinessBookings();
        } else {
          _error = res.message;
        }
      },
    );

    _isSubmitting = false;
    notifyListeners();
    return success;
  }

  // ─── Cancel Booking (User side) ───
  Future<bool> cancelBooking({
    required int bookingId,
    required String reason,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final body = <String, dynamic>{
      'booking_id': bookingId,
      'reason': reason,
    };

    final result = await _repo.cancelBooking(body);
    bool success = false;

    result.fold(
      (err) => _error = err.message,
      (res) {
        if (res.status) {
          success = true;
          final idx = _userBookings.indexWhere((b) => b.id == bookingId);
          if (idx != -1) {
            _userBookings[idx] = BookingModel(
              id: _userBookings[idx].id,
              userId: _userBookings[idx].userId,
              businessId: _userBookings[idx].businessId,
              businessCategory: _userBookings[idx].businessCategory,
              bookingDate: _userBookings[idx].bookingDate,
              bookingTime: _userBookings[idx].bookingTime,
              guestsCount: _userBookings[idx].guestsCount,
              serviceName: _userBookings[idx].serviceName,
              sportName: _userBookings[idx].sportName,
              notes: _userBookings[idx].notes,
              status: 'cancelled',
              rejectionReason: reason,
              createdAt: _userBookings[idx].createdAt,
              advanceAmount: _userBookings[idx].advanceAmount,
              advancePaymentStatus: _userBookings[idx].advancePaymentStatus,
              isBookingActive: false,
              user: _userBookings[idx].user,
              business: _userBookings[idx].business,
            );
          }
        } else {
          _error = res.message;
        }
      },
    );

    _isSubmitting = false;
    notifyListeners();
    return success;
  }

  // ─── Advance Payment Settings ───
  double _advancePlatformFee = 10;
  double get advancePlatformFee => _advancePlatformFee;

  double _advanceGstPercent = 18;
  double get advanceGstPercent => _advanceGstPercent;

  Future<void> fetchAdvancePaymentSettings() async {
    final result = await _repo.getAdvancePaymentSettings();
    result.fold(
      (_) {},
      (settings) {
        _advancePlatformFee = settings.platformFee;
        _advanceGstPercent = settings.gstPercent;
        notifyListeners();
      },
    );
  }

  // ─── Create Advance Payment Order ───
  Future<AdvanceOrderResponse?> createAdvanceOrder(int bookingId) async {
    _isCreatingAdvanceOrder = true;
    _error = null;
    _currentAdvanceOrder = null;
    notifyListeners();

    AdvanceOrderResponse? result;

    debugPrint('🔍 [VM] createAdvanceOrder called for booking #$bookingId');
    final response = await _repo.createAdvanceOrder(bookingId);
    debugPrint('🔍 [VM] Repo response type: ${response.runtimeType}');

    response.fold(
      (err) {
        debugPrint('🔍 [VM] Error fold - statusCode: ${err.statusCode}, message: "${err.message}"');
        debugPrint('🔍 [VM] Error runtimeType: ${err.runtimeType}');
        _error = err.message;
      },
      (res) {
        debugPrint('🔍 [VM] Success fold - status: ${res.status}, message: "${res.message}"');
        debugPrint('🔍 [VM] razorpayOrderId: ${res.razorpayOrderId}, keyId: ${res.keyId}, amount: ${res.amount}');
        if (res.status) {
          _currentAdvanceOrder = res;
          result = res;
        } else {
          _error = res.message;
        }
      },
    );

    _isCreatingAdvanceOrder = false;
    notifyListeners();
    debugPrint('🔍 [VM] Returning result: $result, error: $_error');
    return result;
  }

  // ─── Verify Advance Payment after Razorpay success ───
  Future<bool> verifyAdvancePayment({
    required int bookingId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    bool success = false;

    final result = await _repo.verifyAdvancePayment(
      bookingId: bookingId,
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      razorpaySignature: razorpaySignature,
    );

    result.fold(
      (err) => _error = err.message,
      (res) {
        if (res.status) {
          success = true;
          // Update local user booking to reflect paid status
          final idx = _userBookings.indexWhere((b) => b.id == bookingId);
          if (idx != -1) {
            final old = _userBookings[idx];
            _userBookings[idx] = BookingModel(
              id: old.id,
              userId: old.userId,
              businessId: old.businessId,
              businessCategory: old.businessCategory,
              bookingDate: old.bookingDate,
              bookingTime: old.bookingTime,
              guestsCount: old.guestsCount,
              serviceName: old.serviceName,
              sportName: old.sportName,
              notes: old.notes,
              status: old.status,
              rejectionReason: old.rejectionReason,
              createdAt: old.createdAt,
              advanceAmount: old.advanceAmount,
              advancePaymentStatus: 'paid',
              isBookingActive: true,
              user: old.user,
              business: old.business,
            );
          }
        } else {
          _error = res.message;
        }
      },
    );

    _isSubmitting = false;
    notifyListeners();
    return success;
  }

  // ─── Computed: Pending business bookings count ───
  int get pendingBookingsCount =>
      _businessBookings.where((b) => b.status == 'pending').length;
}
