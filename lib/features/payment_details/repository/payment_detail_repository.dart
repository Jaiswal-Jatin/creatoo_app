import 'package:creatoo/features/payment_details/model/payment_detail_model.dart';

import '../../../core.dart';
import '../model/payment_detail_response.dart';

class PaymentDetailRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, PaymentDetailResponse>> sendPaymentDetailsApi(PaymentDetailModel body) async {
    return await _apiServices.callPostAPI(
      AppUrl.paymentDetailsApi,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parsePaymentDetailResponse,
      body: body.toJson(),
    );
  }

  // Future<Either<AppException, PaymentDetailResponse>>
  //     fetchPaymentDetailsApi() async {
  //   return await _apiServices.callPostAPI(
  //     AppUrl.getPaymentDetailApi,
  //     {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
  //     Parser.parsePaymentDetailResponse,
  //     body: {"user_id": userId},
  //   );
  // }
}
