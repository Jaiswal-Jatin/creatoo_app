import '../../core.dart';

class RazorpayService {
  late Razorpay _razorpay;
  final Function(PaymentSuccessResponse) _paymentSuccessCallback;
  final Function(PaymentFailureResponse) _paymentFailureCallback;
  final SharedPreferencesService _preferencesService =
      SharedPreferencesService();

  RazorpayService(this._paymentSuccessCallback, this._paymentFailureCallback) {
    try {
      _razorpay = Razorpay();

      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

      getUserData();
    } catch (e) {
      log("Razorpay Exception : $e");
    }
  }

  void getUserData() async {
    user = await _preferencesService.getUserData();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    try {
      _paymentSuccessCallback(response);
    } catch (e) {
      log("Razorpay Exception : $e");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    try {
      _paymentFailureCallback(response);
    } catch (e) {
      log("Razorpay Exception : $e");
    }
  }

  void openCheckout({
    required double amount,
    required String orderId,
    String? keyId,                // ← from backend response (preferred)
    String? contact = "7709551921",
    String email = "support@creatoo.co.in",
    String? paymentDescription,
  }) {
    // Fallback key if backend doesn't send one
    final effectiveKey = (keyId != null && keyId.isNotEmpty)
        ? keyId
        : 'rzp_test_QRN3MU56A6QLgI';

    final amountInPaise = (amount * 100).round();

    var options = {
      'key': effectiveKey,
      'amount': amountInPaise,
      'name': Constants.appName,
      'description': paymentDescription ?? "Bill Payment",
      'order_id': orderId,
      'currency': "INR",
      'prefill': {
        'contact': contact,
        'email': email,
      },
      'theme': {'color': '#9759C4'}
    };

    try {
      log("Razorpay Checkout → key: $effectiveKey, orderId: $orderId, amount: $amountInPaise paise");
      _razorpay.open(options);
    } catch (e, stackTrace) {
      log('Error opening Razorpay: $e');
      log('Stack trace: $stackTrace');
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
