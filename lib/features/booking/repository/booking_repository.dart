import 'dart:convert';
import 'package:creatoo/core.dart';
import 'package:creatoo/data/app_exceptions.dart';
import 'package:creatoo/data/network/base_api_services.dart';
import 'package:creatoo/data/network/network_api_service.dart';
import 'package:creatoo/resources/app_url.dart';
import '../model/booking_model.dart';

class BookingRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token ?? ""}',
      };

  // ─── Create Booking Request ───
  Future<Either<AppException, BookingCreateResponse>> createBookingRequest(
      Map<String, dynamic> body) async {
    try {
      final response = await _apiServices.callPostAPI<BookingCreateResponse,
          BookingCreateResponse>(
        AppUrl.createBookingRequest,
        _headers,
        (r) => BookingCreateResponse.fromJson(jsonDecode(r)),
        body: body,
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }

  // ─── Get User Booking History ───
  Future<Either<AppException, BookingListResponse>> getUserHistory() async {
    try {
      final response = await _apiServices
          .callGetAPI<BookingListResponse, BookingListResponse>(
        AppUrl.bookingUserHistory,
        _headers,
        (r) => BookingListResponse.fromJson(jsonDecode(r)),
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }

  // ─── Get Business Booking List ───
  Future<Either<AppException, BookingListResponse>> getBusinessList() async {
    try {
      final response = await _apiServices
          .callGetAPI<BookingListResponse, BookingListResponse>(
        AppUrl.businessBookingList,
        _headers,
        (r) => BookingListResponse.fromJson(jsonDecode(r)),
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }

  // ─── Update Booking Status (Accept/Reject) ───
  Future<Either<AppException, BookingCreateResponse>> updateStatus(
      Map<String, dynamic> body) async {
    try {
      final response = await _apiServices.callPostAPI<BookingCreateResponse,
          BookingCreateResponse>(
        AppUrl.updateBookingStatus,
        _headers,
        (r) => BookingCreateResponse.fromJson(jsonDecode(r)),
        body: body,
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }

  // ─── Cancel Booking (User side) ───
  Future<Either<AppException, BookingCreateResponse>> cancelBooking(
      Map<String, dynamic> body) async {
    try {
      final response = await _apiServices.callPostAPI<BookingCreateResponse,
          BookingCreateResponse>(
        AppUrl.cancelBooking,
        _headers,
        (r) => BookingCreateResponse.fromJson(jsonDecode(r)),
        body: body,
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }

  // ─── Create Advance Payment Order (Razorpay) ───
  Future<Either<AppException, AdvanceOrderResponse>> createAdvanceOrder(
      int bookingId) async {
    try {
      debugPrint('🔍 [REPO] Calling URL: ${AppUrl.createAdvanceOrder}');
      debugPrint('🔍 [REPO] With headers: ${_headers.keys}');
      debugPrint('🔍 [REPO] With body: {"booking_id": $bookingId}');
      final response = await _apiServices.callPostAPI<AdvanceOrderResponse,
          AdvanceOrderResponse>(
        AppUrl.createAdvanceOrder,
        _headers,
        (r) => AdvanceOrderResponse.fromJson(jsonDecode(r)),
        body: {'booking_id': bookingId},
      );
      debugPrint('🔍 [REPO] Response received: ${response.runtimeType}');
      return response;
    } on AppException catch (e) {
      debugPrint('🔍 [REPO] AppException caught: statusCode=${e.statusCode}, message="${e.message}"');
      return Left(e);
    } catch (e) {
      debugPrint('🔍 [REPO] Generic exception caught: $e');
      return Left(AppException(0, e.toString()));
    }
  }

  // ─── Get Advance Payment Settings (platform fee & GST) ───
  Future<Either<AppException, AdvancePaymentSettings>> getAdvancePaymentSettings() async {
    try {
      final response = await _apiServices
          .callGetAPI<AdvancePaymentSettings, AdvancePaymentSettings>(
        AppUrl.advancePaymentSettings,
        _headers,
        (r) => AdvancePaymentSettings.fromJson(jsonDecode(r)),
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }

  // ─── Verify Advance Payment (after Razorpay callback) ───
  Future<Either<AppException, BookingCreateResponse>> verifyAdvancePayment({
    required int bookingId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await _apiServices.callPostAPI<BookingCreateResponse,
          BookingCreateResponse>(
        AppUrl.verifyAdvancePayment,
        _headers,
        (r) => BookingCreateResponse.fromJson(jsonDecode(r)),
        body: {
          'booking_id': bookingId,
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        },
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }
}
