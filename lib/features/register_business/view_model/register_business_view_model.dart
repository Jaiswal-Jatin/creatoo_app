import 'package:creatoo/core.dart';
import 'package:creatoo/features/register_business/model/business_type_response.dart';
import 'package:creatoo/features/register_business/model/register_business_model.dart';
import 'package:creatoo/features/register_business/model/register_business_response_model.dart';
import 'package:creatoo/features/register_business/repository/register_business_repository.dart';
import 'package:creatoo/features/verify_otp/model/verify_otp_model.dart';
import 'package:creatoo/utils/deep_link_service.dart';

class RegisterBusinessViewModel with ChangeNotifier {
  final RegisterBusinessRepository _myRepo = RegisterBusinessRepository();
  late RegisterBusinessModel model;
  List<BusinessType> businessTypeList = [];
  bool isValidating = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ApiResponse<RegisterBusinessResponse> businessResponse =
      ApiResponse.initial();

  setResponse(ApiResponse<RegisterBusinessResponse> response) =>
      businessResponse = response;

  ApiResponse<BusinessTypeResponse> businessTypesResponse =
      ApiResponse.initial();

  setBusinessTypeResponse(ApiResponse<BusinessTypeResponse> response) {
    businessTypesResponse = response;
  }

  setValidatingStatus(status) {
    isValidating = status;
    notifyListeners();
  }

  init(String phone) async {
    isValidating = false;
    model = RegisterBusinessModel();
    model.businessMobile = phone;
    model.roleId = roleId;
    await getBusinessTypes();
  }

  Future<void> registerBusiness() async {
    setResponse(ApiResponse.loading());
    notifyListeners();
    var response = await _myRepo.registerBusiness(model);
    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        setResponse(ApiResponse.completed(r));
        Utils.toastMessage(r.message.toString());
        await saveUserData(businessResponse.data!.data!);
        Navigator.pushNamedAndRemoveUntil(navigatorKey.currentContext!,
            RoutesName.homePage, (route) => false);

        // Check for pending deep link navigation after successful registration
        await Future.delayed(const Duration(milliseconds: 500));
        DeepLinkService.checkPendingNavigation();
      },
    );
    notifyListeners();
  }

  Future<void> getBusinessTypes() async {
    setBusinessTypeResponse(ApiResponse.loading());
    var response = await _myRepo.getBusinessTypesApi();
    response.fold(
      (l) {
        setBusinessTypeResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        setBusinessTypeResponse(ApiResponse.completed(r));
        // Utils.toastMessage(r.message.toString());
        businessTypeList = businessTypesResponse.data!.data!;
      },
    );
    notifyListeners();
  }

  saveUserData(Data data) async {
    final SharedPreferencesService prefs = SharedPreferencesService();
    token = data.token;
    userId = data.id;
    await prefs.saveToken(data.token!);
    await prefs.saveUserId(data.id!);
    prefs.saveUserData(UserData(
      id: data.id,
      email: data.businessEmail,
      mobile: data.businessMobile,
      token: data.token,
      name: data.businessName,
      address: data.businessArea,
    ));
  }

  Future<void> getImageAttachment() async {
    File? file = await ImageHelper.pickImage();
    if (file != null) {
      model.businessImage = file.path;
    } else {
      Utils.toastMessage("Failed to attach image");
    }
    notifyListeners();
  }

  void updateBusinessRegistrationForm(List<String> data) {
    model.businessName = data[0];
    model.businessArea = data[1];
    model.businessAddress = data[2];
    model.businessSiteUrl = data[3];
    print(model.toJson());
    notifyListeners();
  }

  void updateBusinessRepresentativeForm(List<String> data) {
    model.businessFullname = data[0];
    model.businessDesignation = data[1];
    model.businessEmail = data[2];
    // model.businessMobile = data[3];
    print(model.toJson());
    notifyListeners();
  }

  void updateDocumentationForm({bool isGst = true, String value = ""}) {
    if (isGst) {
      model.gstNumber = value;
    } else {
      model.businessType = value;
    }
    // print("GST : ${value} | ${value.length}");
    notifyListeners();
  }
}
