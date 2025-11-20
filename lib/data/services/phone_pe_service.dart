// import 'package:crypto/crypto.dart';
// import 'package:http/http.dart' as http;
//
// import '../../core.dart';
//
// class PhonePeService {
//   final void Function(PaymentResult, bool) _paymentCallback;
// //TODO: UnComment PROD Values
//
//   // String environment = "SANDBOX";
//   // String merchantId = "QUICKENONLINEUAT";
//   String environment = "PRODUCTION"; //PROD
//   String merchantId = "M22EFNQGYNH1V"; //PROD
//   String flowId = "";
//   bool enableLogs = true;
//   String appSchema = "creatoo";
//   // String apiEndPoint = "/pg/v1/pay";
//   // String saltKey = "fae2dfd0-1d1f-4151-9425-87b585fb24ef";
//   String apiEndPoint = "https://api.phonepe.com/apis/hermes/pg/v1/pay"; //PROD
//   String saltKey = "432528db-b655-4748-960c-9957b9ac3861"; //PROD
//   String saltIndex = "1";
//   String callBackUrl = "${AppUrl.baseUrl}/handleWebhook";
//   String? packageName = Platform.isAndroid ? "com.creatoo.app" : "com.creatoo.creatooapp";
//
//   PhonePeService(this._paymentCallback) {
//     _initPhonePeSdk();
//   }
//
//   String _generateFlowId() {
//     return "FL${DateTime.now().millisecondsSinceEpoch}";
//   }
//
//   void _initPhonePeSdk() {
//     flowId = _generateFlowId();
//     try {
//       PhonePePaymentSdk.init(environment, merchantId, flowId, enableLogs).then((isInitialized) {
//         if (isInitialized == true) {
//           debugPrint("PhonePe SDK Initialized Successfully: $environment, $merchantId, $flowId");
//         } else {
//           debugPrint("PhonePe SDK Initialization Failed.");
//         }
//       }).catchError((error) {
//         debugPrint("PhonePe SDK Error: $error");
//       });
//     } catch (e) {
//       debugPrint("Exception: $e");
//     }
//   }
//
//   String _generateEncryptedPayload(Map<String, dynamic> requestPayload) {
//     String jsonPayload = jsonEncode(requestPayload);
//     return base64Encode(utf8.encode(jsonPayload));
//   }
//
//   String _generateChecksum(String base64Payload) {
//     //TODO: try replacing "/pg/v1/pay" with apiEndPoint
//     String payloadWithSalt = base64Payload + "/pg/v1/pay" + saltKey;
//     var bytes = utf8.encode(payloadWithSalt);
//     var digest = sha256.convert(bytes);
//     return digest.toString() + "###" + saltIndex;
//   }
//
//   void startTransaction({
//     required double amount,
//     required String mobileNumber,
//     required String merchantTransactionId,
//   }) {
//     int amountInPaise = (amount * 100).toInt();
//     // int amountInPaise = (1 * 100).toInt();
//
//     String merchantUserId = "MUID$userId";
//
//     Map<String, dynamic> requestPayload = {
//       "merchantId": merchantId,
//       "merchantTransactionId": merchantTransactionId,
//       "merchantUserId": merchantUserId,
//       "amount": amountInPaise,
//       "callbackUrl": callBackUrl,
//       "mobileNumber": mobileNumber,
//       "paymentInstrument": {"type": "PAY_PAGE"}
//     };
//
//     String encryptedPayload = _generateEncryptedPayload(requestPayload);
//     String checksum = _generateChecksum(encryptedPayload);
//
//     try {
//       PhonePePaymentSdk.startTransaction(encryptedPayload, appSchema, checksum, packageName).then((response) {
//         if (response != null) {
//           String status = response['status'].toString();
//           String error = response.containsKey('error') ? response['error'].toString() : "Unknown error";
//
//           if (status == 'SUCCESS') {
//             _paymentCallback(
//                 PaymentResult(
//                   orderId: merchantTransactionId,
//                   isSuccess: true,
//                   message: "Payment Successful!",
//                 ),
//                 true);
//           } else {
//             _paymentCallback(
//                 PaymentResult(
//                   orderId: merchantTransactionId,
//                   isSuccess: false,
//                   message: "Payment Failed: $status",
//                   errorCode: error,
//                 ),
//                 true);
//           }
//         } else {
//           _paymentCallback(
//               PaymentResult(
//                 orderId: merchantTransactionId,
//                 isSuccess: false,
//                 message: "Payment Flow Incomplete",
//               ),
//               true);
//         }
//       }).catchError((error) {
//         debugPrint("Transaction Error: $error");
//         _paymentCallback(
//             PaymentResult(
//               orderId: merchantTransactionId,
//               isSuccess: false,
//               message: "Payment Error",
//               errorCode: error.toString(),
//             ),
//             true);
//       });
//     } catch (e) {
//       debugPrint("Exception: $e");
//       _paymentCallback(
//           PaymentResult(
//             orderId: merchantTransactionId,
//             isSuccess: false,
//             message: "Payment Exception",
//             errorCode: e.toString(),
//           ),
//           true);
//     }
//   }
//
//   Future<void> checkTransactionStatus(String merchantTransactionId) async {
//     final path = "/pg/v1/status/$merchantId/$merchantTransactionId";
//
//     //TODO: Change Sandbox to Prod
//
//     // final url = "https://api-preprod.phonepe.com/apis/pg-sandbox$path";
//     final url = "https://api.phonepe.com/apis/hermes$path"; //PROD
//
//     // Generate SHA256 checksum: SHA256(path + saltKey) + "###" + saltIndex
//     final String payloadToHash = path + saltKey;
//     final String hashed = sha256.convert(utf8.encode(payloadToHash)).toString();
//     final String xVerify = "$hashed###$saltIndex";
//
//     try {
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'X-VERIFY': xVerify,
//           'X-MERCHANT-ID': merchantId,
//         },
//       );
//
//       if (response.statusCode == 200) {
//         debugPrint('Transaction Status Response: ${response.body}');
//         final responseBody = jsonDecode(response.body);
//
//         final bool success = responseBody['success'];
//         final String code = responseBody['code'] ?? '';
//         final String message = responseBody['message'] ?? '';
//         final String state = responseBody['data']?['state'] ?? '';
//
//         if (success && state == 'COMPLETED') {
//           _paymentCallback(
//               PaymentResult(
//                 orderId: merchantTransactionId,
//                 isSuccess: true,
//                 message: "Payment Status Confirmed as SUCCESS",
//               ),
//               false);
//         } else {
//           _paymentCallback(
//               PaymentResult(
//                 orderId: merchantTransactionId,
//                 isSuccess: false,
//                 message: "Status Check Failed: $code - $message",
//                 errorCode: code,
//               ),
//               false);
//         }
//       } else {
//         debugPrint('Non-200 Response: ${response.statusCode}');
//         _paymentCallback(
//             PaymentResult(
//               orderId: merchantTransactionId,
//               isSuccess: false,
//               message: "Failed to fetch payment status",
//               errorCode: response.statusCode.toString(),
//             ),
//             false);
//       }
//     } catch (e) {
//       debugPrint('Exception while checking transaction status: $e');
//       _paymentCallback(
//           PaymentResult(
//             orderId: merchantTransactionId,
//             isSuccess: false,
//             message: "Exception during status check",
//             errorCode: e.toString(),
//           ),
//           false);
//     }
//   }
// }
//
// class PaymentResult {
//   final String orderId;
//   final bool isSuccess;
//   final String message;
//   final String? errorCode;
//
//   PaymentResult({
//     required this.orderId,
//     required this.isSuccess,
//     required this.message,
//     this.errorCode,
//   });
// }
