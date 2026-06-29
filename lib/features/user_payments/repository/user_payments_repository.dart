import 'package:creatoo/core.dart';
import '../../business_payments/model/manual_payment_model.dart';

class TodayVisitCountResponse {
  final int todayCount;
  final String tier;

  TodayVisitCountResponse({required this.todayCount, required this.tier});

  factory TodayVisitCountResponse.fromJson(Map<String, dynamic> json) {
    final d = json['data'] as Map<String, dynamic>?;
    return TodayVisitCountResponse(
      todayCount: d?['today_count'] ?? 0,
      tier: d?['tier'] ?? 'new',
    );
  }
}

class PaymentCalculation {
  final bool isFirstVisit;
  final int discountPercentage;
  final double discountAmount;
  final double billAmount;
  final int pointsRedeemed;
  final double finalAmount;
  final double platformFee;
  final double gstPercent;
  final double gstAmount;
  final double totalAmount;
  final String? businessName;

  PaymentCalculation({
    required this.isFirstVisit,
    required this.discountPercentage,
    required this.discountAmount,
    required this.billAmount,
    required this.pointsRedeemed,
    required this.finalAmount,
    this.platformFee = 0,
    this.gstPercent = 0,
    this.gstAmount = 0,
    this.totalAmount = 0,
    this.businessName,
  });

  factory PaymentCalculation.fromJson(Map<String, dynamic> json) {
    final d = json['data'] as Map<String, dynamic>;
    num parseNum(dynamic val, num defaultVal) {
      if (val == null) return defaultVal;
      if (val is num) return val;
      if (val is String) return num.tryParse(val) ?? defaultVal;
      return defaultVal;
    }

    return PaymentCalculation(
      isFirstVisit: d['is_first_visit'] ?? false,
      discountPercentage: parseNum(d['discount_percentage'], 0).toInt(),
      discountAmount: parseNum(d['discount_amount'], 0).toDouble(),
      billAmount: parseNum(d['bill_amount'], 0).toDouble(),
      pointsRedeemed: parseNum(d['points_redeemed'], 0).toInt(),
      finalAmount: parseNum(d['final_amount'], 0).toDouble(),
      platformFee: parseNum(d['platform_fee'], 0).toDouble(),
      gstPercent: parseNum(d['gst_percent'], 0).toDouble(),
      gstAmount: parseNum(d['gst_amount'], 0).toDouble(),
      totalAmount: parseNum(d['total_amount'], 0).toDouble(),
      businessName: d['business_name'],
    );
  }
}

class RazorpayOrderResponse {
  final String razorpayOrderId;
  final double amount;
  final int amountInPaise;
  final String keyId;

  RazorpayOrderResponse({
    required this.razorpayOrderId,
    required this.amount,
    required this.amountInPaise,
    required this.keyId,
  });

  factory RazorpayOrderResponse.fromJson(Map<String, dynamic> json) {
    final d = json['data'] as Map<String, dynamic>;
    return RazorpayOrderResponse(
      razorpayOrderId: d['razorpay_order_id'] ?? '',
      amount: (d['amount'] ?? 0).toDouble(),
      amountInPaise: d['amount_in_paise'] ?? 0,
      keyId: d['key_id'] ?? '',
    );
  }
}

class UserPaymentsRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, ManualPaymentResponse>> getPayments() async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token ?? ""}',
      };
      dynamic response = await _apiServices.callPostAPI<ManualPaymentResponse, ManualPaymentResponse>(
        AppUrl.manualUserPayments,
        headers,
        (response) => ManualPaymentResponse.fromJson(jsonDecode(response)),
        body: {},
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }

  Future<Either<AppException, PaymentCalculation>> calculatePayment({
    required int businessId,
    required double billAmount,
    int pointsRedeemed = 0,
  }) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token ?? ""}',
      };
      dynamic response = await _apiServices.callPostAPI<PaymentCalculation, PaymentCalculation>(
        AppUrl.manualCalculatePayment,
        headers,
        (response) => PaymentCalculation.fromJson(jsonDecode(response)),
        body: {
          'business_id': businessId,
          'bill_amount': billAmount,
          'points_redeemed': pointsRedeemed,
        },
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }

  Future<Either<AppException, Map<String, dynamic>>> setPaymentPaidAt({
    required int paymentId,
  }) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token ?? ""}',
      };
      dynamic response = await _apiServices.callPostAPI<Map<String, dynamic>, Map<String, dynamic>>(
        AppUrl.manualSetPaymentPaidAt,
        headers,
        (response) => jsonDecode(response) as Map<String, dynamic>,
        body: {'payment_id': paymentId},
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }

  Future<Either<AppException, TodayVisitCountResponse>> getTodayVisitCount(int businessId) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token ?? ""}',
      };
      final url = '${AppUrl.todayVisitCount}?business_id=$businessId';
      dynamic response = await _apiServices.callGetAPI<TodayVisitCountResponse, TodayVisitCountResponse>(
        url,
        headers,
        (response) => TodayVisitCountResponse.fromJson(jsonDecode(response)),
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }

  Future<Either<AppException, RazorpayOrderResponse>> createRazorpayOrder({
    required int businessId,
    required double billAmount,
    int pointsRedeemed = 0,
    double pointsValue = 0,
    required double finalAmount,
    int? discountPercentage,
    double? discountAmount,
    double? totalAmount,
  }) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token ?? ""}',
      };
      final body = <String, dynamic>{
        'business_id': businessId,
        'bill_amount': billAmount,
        'points_redeemed': pointsRedeemed,
        'points_value': pointsValue,
        'final_amount': finalAmount,
      };
      if (discountPercentage != null) body['discount_percentage'] = discountPercentage;
      if (discountAmount != null) body['discount_amount'] = discountAmount;
      if (totalAmount != null) body['total_amount'] = totalAmount;

      dynamic response = await _apiServices.callPostAPI<RazorpayOrderResponse, RazorpayOrderResponse>(
        AppUrl.manualCreateRazorpayOrder,
        headers,
        (response) => RazorpayOrderResponse.fromJson(jsonDecode(response)),
        body: body,
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }

  Future<Either<AppException, Map<String, dynamic>>> submitPayment({
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
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token ?? ""}',
      };
      final body = <String, dynamic>{
        'business_id': businessId,
        'bill_amount': billAmount,
        'points_redeemed': pointsRedeemed,
        'points_value': pointsValue,
        'final_amount': finalAmount,
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      };
      if (discountPercentage != null) body['discount_percentage'] = discountPercentage;
      if (discountAmount != null) body['discount_amount'] = discountAmount;
      if (platformFee > 0) body['platform_fee'] = platformFee;
      if (gstPercent > 0) body['gst_percent'] = gstPercent;
      if (gstAmount > 0) body['gst_amount'] = gstAmount;

      dynamic response = await _apiServices.callPostAPI<Map<String, dynamic>, Map<String, dynamic>>(
        AppUrl.manualSubmitPayment,
        headers,
        (response) => jsonDecode(response) as Map<String, dynamic>,
        body: body,
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }
}
