import '../../../core.dart';
import '../model/add_business_wallet_transaction_response.dart';
import '../model/add_post_response_model.dart';
import '../model/payment_model.dart';
import '../model/payment_response_model.dart';
import '../model/setting_response_model.dart';

class AddPostPaymentSummaryRepository with ChangeNotifier {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, AddPostResponseModel>> addPostApi(dynamic body) async {
    return await _apiServices.callPostAPI(
      AppUrl.addPost,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseAddPostResponse,
      body: body,
    );
  }

  Future<Either<AppException, PaymentResponse>> addPostPaymentStatusApi(PaymentModel body) async {
    return await _apiServices.callPostAPI(
      AppUrl.postPaymentStatus,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseRazorpayPaymentResponse,
      body: body.toJson(),
    );
  }

  Future<Either<AppException, SettingResponse>> settingApi(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.settingApi,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseSettingResponse,
      body: body,
    );
  }

  Future<Either<AppException, AddBusinessWalletTransactionResponse>> addBusinessTransactionApi(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.addBusinessWalletTransactionApi,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseAddBusinessWalletTransactionResponse,
      body: body,
    );
  }
}
