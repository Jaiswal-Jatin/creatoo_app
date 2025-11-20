import 'package:creatoo/core.dart';
import 'package:creatoo/features/category/model/BusinessTypeResponseModel.dart';

class CategoryRepository with ChangeNotifier {
  final BaseApiServices _apiServices = NetworkApiService();
  int? userType;

  initialiseUser() async {
    final SharedPreferencesService prefs = SharedPreferencesService();
    return userType = await prefs.getUserRoleId();
  }

  Future<Either<AppException, BusinessTypeResponseModel>> getBusinessTypesApi() async {
    return await _apiServices.callGetAPI(
      AppUrl.getBusinessTypes,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseGetBusinessTypesResponseNew,
      disableTokenValidityCheck: true,
    );
  }
}
