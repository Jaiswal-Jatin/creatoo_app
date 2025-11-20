import 'package:creatoo/features/bill_payment/model/apply_offers_response_model.dart';
import 'package:creatoo/features/bill_payment/model/payment_status_response.dart';
import 'package:creatoo/features/bill_payment/model/process_payment_status_response.dart';

import '../../../core.dart';
import '../../search/model/business_details_response_model.dart';
import '../model/create_order_response_model.dart';

class BillPaymentRepository with ChangeNotifier {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, BusinessDetailsResponseModel>> getBusinessDetails(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.viewProfile,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseGetBusinessDetailsResponse,
      body: body,
    );
  }

  Future<Either<AppException, CreateOrderResponseModel>> createOrderApi(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.createOrderApi,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseCreateOrderResponse,
      body: body,
    );
  }

  Future<Either<AppException, ApplyOffersResponseModel>> applyOffersApi(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.applyOffers,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseApplyOffersResponse,
      body: body,
    );
  }

  Future<Either<AppException, PaymentStatusResponse>> paymentStatusApi(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.paymentStatus,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parsePaymentStatusResponse,
      body: body,
    );
  }

  Future<Either<AppException, PaymentStatusResponse>> checkTransactionStatusApi(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.checkTransactionStatus,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parsePaymentStatusResponse,
      body: body,
    );
  }

  Future<Either<AppException, ProcessPaymentStatusResponse>> processPaymentApi(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.processPayment,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseProcessPaymentStatusResponse,
      body: body,
    );
  }
}
