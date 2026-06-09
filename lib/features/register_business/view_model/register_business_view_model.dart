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
  List<String> businessCategories = ['restaurant', 'salon', 'turf'];
  bool isValidating = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Core Business Form Controllers
  late TextEditingController businessNameController;
  late TextEditingController businessAreaController;
  late TextEditingController businessAddressController;
  late TextEditingController businessSiteUrlController;

  // Representative Details
  late TextEditingController businessFullnameController;
  late TextEditingController businessDesignationController;
  late TextEditingController businessEmailController;

  // Documentation
  late TextEditingController gstNumberController;
  late TextEditingController upiIdController;

  // Restaurant dynamic inputs
  late TextEditingController seatingCapacityController;
  bool isVegOnly = false;
  List<String> selectedCuisines = [];

  // Salon dynamic inputs
  late TextEditingController stylistsCountController;
  String selectedGenderSupport = 'unisex';

  // Turf dynamic inputs
  String selectedTurfSize = '7v7';
  String selectedGroundType = 'Artificial Grass';
  List<String> selectedSports = [];

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

    // Initialize core form controllers
    businessNameController = TextEditingController();
    businessAreaController = TextEditingController();
    businessAddressController = TextEditingController();
    businessSiteUrlController = TextEditingController();
    businessFullnameController = TextEditingController();
    businessDesignationController = TextEditingController();
    businessEmailController = TextEditingController();
    gstNumberController = TextEditingController();
    upiIdController = TextEditingController();
    
    // Initialize category input controllers and models
    seatingCapacityController = TextEditingController();
    stylistsCountController = TextEditingController();
    isVegOnly = false;
    selectedCuisines = [];
    selectedGenderSupport = 'unisex';
    selectedTurfSize = '7v7';
    selectedGroundType = 'Artificial Grass';
    selectedSports = [];

    await getBusinessTypes();
  }

  @override
  void dispose() {
    businessNameController.dispose();
    businessAreaController.dispose();
    businessAddressController.dispose();
    businessSiteUrlController.dispose();
    businessFullnameController.dispose();
    businessDesignationController.dispose();
    businessEmailController.dispose();
    gstNumberController.dispose();
    upiIdController.dispose();
    seatingCapacityController.dispose();
    stylistsCountController.dispose();
    super.dispose();
  }

  Future<void> registerBusiness() async {
    setResponse(ApiResponse.loading());
    notifyListeners();

    // Map core text controllers to model
    model.businessName = businessNameController.text.trim();
    model.businessArea = businessAreaController.text.trim();
    model.businessAddress = businessAddressController.text.trim();
    model.businessSiteUrl = businessSiteUrlController.text.trim().isNotEmpty ? businessSiteUrlController.text.trim() : null;
    model.businessFullname = businessFullnameController.text.trim();
    model.businessDesignation = businessDesignationController.text.trim();
    model.businessEmail = businessEmailController.text.trim();
    model.gstNumber = gstNumberController.text.trim().toUpperCase().isNotEmpty ? gstNumberController.text.trim().toUpperCase() : null;
    model.upiId = upiIdController.text.trim().isNotEmpty ? upiIdController.text.trim() : null;

    // Map dynamic category attributes
    if (model.businessCategory == 'restaurant') {
      model.categoryAttributes = {
        'cuisine_type': selectedCuisines,
        'is_veg_only': isVegOnly,
        'seating_capacity': seatingCapacityController.text.trim().isNotEmpty ? int.tryParse(seatingCapacityController.text.trim()) : null,
      };
    } else if (model.businessCategory == 'salon') {
      final attrs = <String, dynamic>{'gender_support': selectedGenderSupport};
      if (stylistsCountController.text.trim().isNotEmpty) {
        attrs['stylists'] = List.generate(
          int.tryParse(stylistsCountController.text.trim()) ?? 1,
          (i) => "Stylist ${i + 1}",
        );
      }
      model.categoryAttributes = attrs;
    } else if (model.businessCategory == 'turf') {
      model.categoryAttributes = {
        'turf_size': selectedTurfSize,
        'ground_type': selectedGroundType,
        'sport_types': selectedSports,
      };
    }

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

  void updateBusinessCategory(String value) {
    model.businessCategory = value;
    notifyListeners();
  }

  void updateUpiId(String value) {
    model.upiId = value.trim();
    notifyListeners();
  }
}
