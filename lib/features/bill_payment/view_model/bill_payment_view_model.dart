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

  ApiResponse<BusinessDetailsResponseModel> businessDetailsResponse = ApiResponse.initial();

  setBusinessDetailsResponse(ApiResponse<BusinessDetailsResponseModel> response) {
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
    final result = PaymentResult(
      isSuccess: false,
      message: response.message ?? "Payment failed",
      orderId: merchantTransactionId ?? "",
      errorCode: response.code.toString(),
    );
    await paymentStatusApiCall(result);
    Utils.toastMessage("Payment Failed ❌");
    Navigator.pop(navigatorKey.currentContext!);
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
    setBusinessDetailsResponse(ApiResponse.loading());
    notifyListeners();

    var data = {
      "user_id": userId,
      // "business_id": businessDescription?.id,
      "token": token,
      "order_id": result.orderId,
      "payment_status": result.isSuccess ? "SUCCESS" : "FAILED",
      "payment_error_message": result.errorCode ?? "",
    };

    var response = await _myRepo.paymentStatusApi(data);
    response.fold(
      (l) {
        Navigator.pop(navigatorKey.currentContext!);
        setBusinessDetailsResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        if (result.isSuccess) {
          orderId = result.orderId;
          businessName = r.data?.businessName;
          businessId = r.data?.businessId;
          Navigator.pushNamed(
            navigatorKey.currentContext!,
            RoutesName.paymentSuccessView,
          );
        } else {}
        setBusinessDetailsResponse(ApiResponse.completed(businessDetailsResponse.data));
        paymentData = r.data;
      },
    );
    notifyListeners();
  }

  Future<void> applyOffersApiCall() async {
    setBusinessDetailsResponse(ApiResponse.loading());
    notifyListeners();
    var data = {
      "user_id": userId,
      "business_id": businessDescription?.id,
      "token": token,
      "bill_amount": _amount,
      "referrer_code": (referralCodeController.text.isNotEmpty) ? referralCodeController.text : null,
    };
    var response = await _myRepo.applyOffersApi(data);
    response.fold(
      (l) {
        setBusinessDetailsResponse(ApiResponse.completed(businessDetailsResponse.data));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        setBusinessDetailsResponse(ApiResponse.completed(businessDetailsResponse.data));
        billSummary = r.data;
        merchantTransactionId = r.data?.merchantTransactionId;
        Navigator.pushNamed(
          navigatorKey.currentContext!,
          RoutesName.proceedToPay,
        );
      },
    );
    notifyListeners();
  }

  Future<void> startPayment({required String? orderId, required double amount, String? mobileNumber}) async {
    if (orderId != null) {
      razorPayService.openCheckout(
        // amount: 1.00,
        amount: amount,
        orderId: orderId,
        contact: mobileNumber,
        paymentDescription: "Bill Payment",
      );
    } else {
      Utils.toastMessage("Unable to start payment. Missing order ID or amount.");
    }
  }

  void disposeService() {
    razorPayService.dispose();
  }

  Future<void> checkTransactionStatusApiCall({required String orderId, required Future<void> Function() onSuccess}) async {
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
    setBusinessDetailsResponse(ApiResponse.loading());
    notifyListeners();

    var data = {
      "token": token,
      "order_id": billSummary?.merchantTransactionId,
    };

    var response = await _myRepo.processPaymentApi(data);
    response.fold(
      (l) {
        setBusinessDetailsResponse(ApiResponse.error(l.message));
        debugPrint(l.message);
      },
      (r) async {
        setBusinessDetailsResponse(ApiResponse.completed(businessDetailsResponse.data));
        debugPrint("Orders Status updated");
      },
    );
    notifyListeners();
  }
}
