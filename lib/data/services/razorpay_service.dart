import '../../core.dart';

class RazorpayService {
  late Razorpay _razorpay;
  final Function(PaymentSuccessResponse) _paymentSuccessCallback;
  final Function(PaymentFailureResponse) _paymentFailureCallback;
  final SharedPreferencesService _preferencesService = SharedPreferencesService();

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
    String? contact = "7709551921",
    String email = "support@creatoo.co.in",
    String? paymentDescription,
  }) {
    var options = {
      'key': dotenv.env["KEY_ID"],
      'amount': amount * 100,
      "currency": "INR",
      'name': Constants.appName,
      'order_id': orderId,
      'description': paymentDescription,
      'prefill': {
        'contact': contact,
        'email': email,
      },
      "image": Constants.appLogo,
      "send_sms_hash": true,
      'theme.color': '#9759C4',
      'theme.backdrop_color': '#9759C4',
    };

    try {
      print("Opening Razorpay with options: $options");
      _razorpay.open(options);
    } catch (e) {
      print('Error opening Razorpay: $e');
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
