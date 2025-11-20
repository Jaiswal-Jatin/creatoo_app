import '../../../core.dart';

class StartupRepository{
  final BaseApiServices _apiServices = NetworkApiService();

  // Future<dynamic> selectRoleApi() async {
  //   return await _apiServices.callGetAPI(
  //     AppUrl.roleSelection,
  //     {},
  //     Parser.parseCountriesCodeResponse,
  //   );
  // }
}