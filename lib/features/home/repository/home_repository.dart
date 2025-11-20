import 'package:creatoo/core.dart';
import 'package:creatoo/features/business_profile/repository/business_profile_repository.dart';

import '../model/home_screen_response_model.dart';

class HomeRepository extends BusinessProfileRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, HomeDataResponse>> getHomeDataApi() async {
    return await _apiServices.callPostAPI(
      AppUrl.homeData,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseHomeDataResponse,
      body: {"user_id": userId},
    );
  }
}
