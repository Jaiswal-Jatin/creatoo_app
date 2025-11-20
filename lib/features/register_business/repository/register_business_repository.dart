import 'package:creatoo/core.dart';
import 'package:creatoo/features/register_business/model/business_type_response.dart';
import 'package:creatoo/features/register_business/model/register_business_model.dart';
import 'package:creatoo/features/register_business/model/register_business_response_model.dart';

class RegisterBusinessRepository with ChangeNotifier {
  final BaseApiServices _apiServices = NetworkApiService();
  int? userType;

  initialiseUser() async {
    final SharedPreferencesService prefs = SharedPreferencesService();
    return userType = await prefs.getUserRoleId();
  }

  Future<Either<AppException, RegisterBusinessResponse>> registerBusiness(
      RegisterBusinessModel data) async {
    return await _apiServices.callPostAPIForm(
      AppUrl.registerBusiness,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseRegisterBusinessResponse,
      body: data.toJson(),
      imageFieldName: "business_image",
      path: data.businessImage!,
      disableTokenValidityCheck: true,
    );
  }

  Future<Either<AppException, BusinessTypeResponse>>
      getBusinessTypesApi() async {
    return await _apiServices.callGetAPI(
      AppUrl.getBusinessTypes,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseGetBusinessTypesResponse,
      disableTokenValidityCheck: true,
    );
  }
}
