import '../../../core.dart';
import '../../search/model/business_details_response_model.dart';
import '../model/apply_offers_response_model.dart';
import '../model/payment_result_model.dart';
import '../model/payment_status_response.dart';
import '../repository/bill_payment_repository.dart';

class BillPaymentViewModel with ChangeNotifier {
  final BillPaymentRepository _myRepo = BillPaymentRepository();
  late RazorpayService razorPayService;
  bool isLoading = false;
  double? _amount;
  BusinessDescription? businessDescription;
  TextEditingController amountController = TextEditingController();
  TextEditingController referralCodeController = TextEditingController();
  String? merchantTransactionId = "";
  BillSummary? billSummary;
  PaymentData? paymentData;
  int? businessId;
  String? businessName;
  String? orderId;
  bool autoFocus = true;

  ApiResponse<BusinessDetailsResponseModel> businessDetailsResponse =
      ApiResponse.initial();

  setBusinessDetailsResponse(
      ApiResponse<BusinessDetailsResponseModel> response) {
    businessDetailsResponse = response;
  }

  double? get amount => _amount;

  void setAmount(double newAmount) {
    _amount = newAmount;
    notifyListeners();
  }

  init() async {
    razorPayService = RazorpayService(
      _handlePaymentSuccess,
      _handlePaymentError,
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final result = PaymentResult(
      isSuccess: true,
      message: "Payment successful",
      orderId: response.orderId ?? "",
      errorCode: null,
    );
    await paymentStatusApiCall(result);
    debugPrint("Payment Success: ${response.paymentId}");
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    debugPrint("Razorpay Error Code: ${response.code}");
    debugPrint("Razorpay Error Message: ${response.message}");
    debugPrint("Razorpay Error Details: ${response.error}");

    Utils.toastMessage("Payment Error: ${response.message} ❌");
  }

  Future<void> getBusinessDetailsApi({required int id}) async {
    setBusinessDetailsResponse(ApiResponse.loading());
    var data = {"role_id": Constants.businessUser, "id": id, "token": token};
    var response = await _myRepo.getBusinessDetails(data);
    response.fold(
      (l) {
        setBusinessDetailsResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        setBusinessDetailsResponse(ApiResponse.completed(r));
        businessDescription = r.data;
      },
    );
    notifyListeners();
  }

  Future<void> paymentStatusApiCall(PaymentResult result) async {
    debugPrint('\n\n=== [${DateTime.now()}] Starting paymentStatusApiCall ===');
    debugPrint('📤 Payment Result:');
    debugPrint('🔹 Is Success: ${result.isSuccess}');
    debugPrint('🔹 Order ID: ${result.orderId}');
    debugPrint('🔹 Message: ${result.message}');
    debugPrint('🔹 Error Code: ${result.errorCode}');

    setBusinessDetailsResponse(ApiResponse.loading());
    notifyListeners();

    var data = {
      "user_id": userId,
      "order_id": result.orderId,
      "payment_status": "SUCCESS", // AS PER REQUIREMENT: MUST BE "SUCCESS"
      // Optional/Additional tracking data
      "business_id": businessDescription?.id,
      "token": token,
      "bill_amount": billSummary?.originalBill,
      "original_bill_amount": billSummary?.originalBill,
      "discounted_bill": billSummary?.discountedBill,
      "final_bill_amount": billSummary?.finalBillAmount,
      "discount_percentage": billSummary?.discountPercentage,
      "discount_applied": billSummary?.discountApplied,
      "platform_fee": billSummary?.platformFee,
      "convenience_fee": billSummary?.convenienceFee,
      "loyalty_points_will_earn": billSummary?.pointsYouWillEarn,
      "total_points_for_business": billSummary?.totalPointsForBusiness,
      "points_redeemed_here": billSummary?.pointsRedeemedHere,
    };

    debugPrint('\n📦 API Request Payload:');
    debugPrint(data.toString());

    var response = await _myRepo.paymentStatusApi(data);
    response.fold(
      (l) {
        debugPrint('\n❌ Payment Status API Error:');
        debugPrint('🔴 Error Message: ${l.message}');
        Navigator.pop(navigatorKey.currentContext!);
        setBusinessDetailsResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        debugPrint('\n✅ Payment Status API Success:');
        debugPrint('🟢 Response Data: ${r.data}');
        debugPrint('🟢 Business Name: ${r.data?.businessName}');
        debugPrint('🟢 Business ID: ${r.data?.businessId}');
        debugPrint('🟢 Total Bill: ${r.data?.totalBill}');
        debugPrint('🟢 Final Bill: ${r.data?.finalBill}');
        debugPrint('🟢 Receipt Name: ${r.data?.receiptName}');
        debugPrint('🟢 Created At: ${r.data?.createdAt}');

        // CRITICAL FIX: Set paymentData BEFORE navigation
        paymentData = r.data;

        // FALLBACK: If API returns null data, use billSummary and businessDescription
        if (paymentData != null) {
          // Check if critical fields are null and populate from existing data
          if (paymentData!.totalBill == null &&
              billSummary?.originalBill != null) {
            paymentData = PaymentData(
              businessName: paymentData!.businessName ??
                  businessDescription?.businessName,
              businessId: paymentData!.businessId ?? businessDescription?.id,
              totalBill: billSummary?.originalBill?.toInt(),
              finalBill: billSummary?.finalBillAmount,
              createdAt: paymentData!.createdAt ?? DateTime.now(),
              receiptName:
                  paymentData!.receiptName ?? businessDescription?.businessName,
              orderId: paymentData!.orderId ?? result.orderId,
            );
            debugPrint(
                '\n⚠️ API returned null data, using fallback from billSummary');
            debugPrint('🔄 Fallback totalBill: ${billSummary?.originalBill}');
            debugPrint(
                '🔄 Fallback finalBill: ${billSummary?.finalBillAmount}');
            debugPrint(
                '🔄 Fallback businessName: ${businessDescription?.businessName}');
          }
        }

        if (result.isSuccess) {
          orderId = result.orderId;
          businessName =
              r.data?.businessName ?? businessDescription?.businessName;
          businessId = r.data?.businessId;

          debugPrint('\n🔜 Data assigned to ViewModel:');
          debugPrint('🔹 orderId: $orderId');
          debugPrint('🔹 businessName: $businessName');
          debugPrint('🔹 businessId: $businessId');
          debugPrint('🔹 paymentData: $paymentData');
          debugPrint('🔹 paymentData.totalBill: ${paymentData?.totalBill}');
          debugPrint('🔹 paymentData.finalBill: ${paymentData?.finalBill}');
          debugPrint('🔹 paymentData.receiptName: ${paymentData?.receiptName}');
          debugPrint('🔹 paymentData.createdAt: ${paymentData?.createdAt}');

          debugPrint('\n🚀 Navigating to PaymentSuccessView...');
          Navigator.pushNamed(
            navigatorKey.currentContext!,
            RoutesName.paymentSuccessView,
          );
        } else {
          debugPrint('\n⚠️ Payment was not successful, skipping navigation');
        }
        setBusinessDetailsResponse(
            ApiResponse.completed(businessDetailsResponse.data));
      },
    );
    notifyListeners();
    debugPrint('\n🏁 Completed paymentStatusApiCall');
    debugPrint('==================================================\n');
  }

  Future<void> applyOffersApiCall() async {
    // Print API call start with timestamp
    debugPrint('\n\n=== [${DateTime.now()}] Starting applyOffersApiCall ===');

    // Print request details
    debugPrint('📤 Request Details:');
    debugPrint('🔹 API Endpoint: applyOffersApi');
    debugPrint('🔹 User ID: $userId');
    debugPrint('🔹 Business ID: ${businessDescription?.id}');
    debugPrint('🔹 Business Name: ${businessDescription?.businessName}');
    debugPrint('🔹 Amount: $_amount');
    debugPrint(
        '🔹 Referral Code: ${referralCodeController.text.isNotEmpty ? referralCodeController.text : 'Not provided'}');
    debugPrint('🔹 Timestamp: ${DateTime.now().toIso8601String()}');

    setBusinessDetailsResponse(ApiResponse.loading());
    notifyListeners();

    var data = {
      "user_id": userId,
      "business_id": businessDescription?.id,
      "token": token,
      "bill_amount": _amount,
      "referrer_code": (referralCodeController.text.isNotEmpty)
          ? referralCodeController.text
          : null,
    };

    debugPrint('\n📦 Request Payload:');
    debugPrint(data.toString());

    try {
      debugPrint('\n🔄 Sending API request...');
      var startTime = DateTime.now();
      var response = await _myRepo.applyOffersApi(data);
      var endTime = DateTime.now();
      var duration = endTime.difference(startTime);

      debugPrint('\n⏱️ API Response Time: ${duration.inMilliseconds}ms');

      response.fold(
        (l) {
          debugPrint('\n❌ API Error:');
          debugPrint('🔴 Status Code: ${l.statusCode}');
          debugPrint('🔴 Error Message: ${l.message}');
          if (l.data != null) {
            debugPrint('🔴 Error Data: ${l.data}');
          }
          debugPrint('🔴 Timestamp: ${DateTime.now().toIso8601String()}');

          setBusinessDetailsResponse(
              ApiResponse.completed(businessDetailsResponse.data));

          // Check for discount not set error
          String errorMsg = l.message.toString().toLowerCase();
          if (errorMsg.contains('discountpercentage') ||
              errorMsg.contains('discount') &&
                  errorMsg.contains('not a function')) {
            Utils.toastMessage(
                "This business has not set discount. You can't pay right now. Please contact the business.");
          } else {
            Utils.toastMessage(l.message.toString());
          }
        },
        (r) async {
          debugPrint('\n✅ API Success:');
          debugPrint('🟢 Status: Success');
          debugPrint(
              '🟢 Merchant Transaction ID: ${r.data?.merchantTransactionId}');
          debugPrint('🟢 Original Bill: ${r.data?.originalBill}');
          debugPrint(
              '🟢 Discount Applied: ${r.data?.discountApplied} (${r.data?.discountPercentage}%)');
          debugPrint('🟢 Final Bill Amount: ${r.data?.finalBillAmount}');
          debugPrint('🟢 Points You Will Earn: ${r.data?.pointsYouWillEarn}');
          debugPrint('🟢 Timestamp: ${DateTime.now().toIso8601String()}');

          // Print full response data
          debugPrint('\n📥 Full Response Data:');
          debugPrint(r.data?.toJson().toString() ?? 'No data in response');

          setBusinessDetailsResponse(
              ApiResponse.completed(businessDetailsResponse.data));
          billSummary = r.data;
          merchantTransactionId = r.data?.merchantTransactionId;

          debugPrint('\n🔜 Navigating to payment screen...');
          Navigator.pushNamed(
            navigatorKey.currentContext!,
            RoutesName.proceedToPay,
          );
        },
      );
    } catch (e, stackTrace) {
      debugPrint('\n❗ Exception in applyOffersApiCall:');
      debugPrint('🔴 Error: $e');
      debugPrint('🔴 Stack Trace: $stackTrace');
      debugPrint('🔴 Timestamp: ${DateTime.now().toIso8601String()}');
      Utils.toastMessage('An error occurred while processing your request');
    } finally {
      notifyListeners();
      debugPrint(
          '\n🏁 Completed applyOffersApiCall at ${DateTime.now().toIso8601String()}');
      debugPrint('==================================================\n');
    }
  }

  Future<void> startPayment(
      {required String? orderId,
      required double amount,
      String? mobileNumber}) async {
    if (orderId != null) {
      razorPayService.openCheckout(
        // amount: 1.00,
        amount: amount,
        orderId: orderId,
        contact: mobileNumber,
        paymentDescription: "Bill Payment",
      );
    } else {
      Utils.toastMessage(
          "Unable to start payment. Missing order ID or amount.");
    }
  }

  void disposeService() {
    razorPayService.dispose();
  }

  Future<void> checkTransactionStatusApiCall(
      {required String orderId,
      required Future<void> Function() onSuccess}) async {
    var data = {
      "user_id": userId,
      "token": token,
      "order_id": orderId,
    };

    var response = await _myRepo.checkTransactionStatusApi(data);
    response.fold(
      (l) {
        Navigator.pop(navigatorKey.currentContext!);
        setBusinessDetailsResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        await onSuccess();
      },
    );
    notifyListeners();
  }

  Future<void> processPaymentStatusApiCall() async {
    // notifyListeners(); // Don't trigger loading to avoid closing Razorpay

    var data = {
      "order_id": billSummary?.merchantTransactionId,
    };

    var response = await _myRepo.processPaymentApi(data);
    response.fold(
      (l) {
        // setBusinessDetailsResponse(ApiResponse.error(l.message)); // Don't disrupt the view
        debugPrint("Process Payment Error: ${l.message}");
      },
      (r) async {
        debugPrint("Orders Status updated to Processing");
      },
    );
  }
}
