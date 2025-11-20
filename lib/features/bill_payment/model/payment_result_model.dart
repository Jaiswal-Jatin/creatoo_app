class PaymentResult {
  final String orderId;
  final bool isSuccess;
  final String message;
  final String? errorCode;

  PaymentResult({
    required this.orderId,
    required this.isSuccess,
    required this.message,
    this.errorCode,
  });
}
