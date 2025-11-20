import 'package:creatoo/core.dart';
import '../model/creator_creatoo_transaction_response.dart';

class CreatorCreatooWalletRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, CreatorCreatooPointTransactionResponse>>
      fetchCreatooPointsTransactionApi(dynamic body) async {
    return await _apiServices.callPostAPI(
      AppUrl.creatooPointsTransactionApi,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseCreatorCreatooPointTransactionResponse,
      body: body,
    );
  }
}
