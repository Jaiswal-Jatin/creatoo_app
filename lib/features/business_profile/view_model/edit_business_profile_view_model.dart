import 'package:creatoo/core.dart';
import 'package:creatoo/features/business_profile/model/business_desription_request_model.dart';
import 'package:creatoo/features/business_profile/model/business_profile_response.dart';
import 'package:creatoo/features/business_profile/model/set_discount_request_model.dart';
import 'package:creatoo/features/business_profile/repository/business_profile_repository.dart';
import 'package:creatoo/features/register_business/model/register_business_model.dart';

import '../../verify_otp/model/verify_otp_model.dart';

class EditBusinessProfileViewModel with ChangeNotifier {
  final BusinessProfileRepository _myRepo = BusinessProfileRepository();

  TextEditingController? businessNameController;
  TextEditingController? businessAreaController;
  TextEditingController? businessCompleteAddressController;
  TextEditingController? fromTimeController;
  TextEditingController? toTimeController;
  TextEditingController? businessWebsiteController;
  TextEditingController? businessFullNameController;
  TextEditingController? businessDesignationController;
  TextEditingController? businessEmailController;
  TextEditingController? businessMobileController;
  TextEditingController? businessGstNoController;

  TextEditingController? priceRangeController;
  TextEditingController? setFirstTimeDiscountController;
  TextEditingController? setRegularDiscountController;
  TextEditingController? minOrderValueController;
  TextEditingController? expiryInDaysController;
  TextEditingController? amountController;
  TextEditingController? noOfPeopleController;

  String? selectedExpiryDays;
  bool showOtherField = false;
  String? _selectedTab;
  String? errorText;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isEditing = false;
  late RegisterBusinessModel model = RegisterBusinessModel();

  String? get selectedTab => _selectedTab;

  BusinessImage? businessImage;
  BusinessImage? businessImage1;
  BusinessImage? businessImage2;
  BusinessImage? businessImage3;
  BusinessImage? businessImage4;
  BusinessImage? businessImage5;

  BusinessImage? menuImage1;
  BusinessImage? menuImage2;
  BusinessImage? menuImage3;
  BusinessImage? menuImage4;
  BusinessImage? menuImage5;

  int deletedIndex = 0;
  int? profileIndex;
  bool isDropdownOpen = false;

  void toggleDropdown() {
    isDropdownOpen = !isDropdownOpen;
    notifyListeners();
  }

  void setErrorText(String? error) {
    errorText = error;
    notifyListeners();
  }

  enableEditing(value) {
    isEditing = value;
    notifyListeners();
  }

  void setIndex(int value) {
    profileIndex = value;
    notifyListeners();
  }

  ApiResponse<BusinessProfileResponse> profileResponse = ApiResponse.loading();

  setResponse(ApiResponse<BusinessProfileResponse> response) {
    profileResponse = response;
  }

  init(String initialTab) async {
    businessNameController = TextEditingController();
    businessAreaController = TextEditingController();
    businessCompleteAddressController = TextEditingController();
    fromTimeController = TextEditingController();
    toTimeController = TextEditingController();
    businessWebsiteController = TextEditingController();
    businessFullNameController = TextEditingController();
    businessDesignationController = TextEditingController();
    businessEmailController = TextEditingController();
    businessMobileController = TextEditingController();
    businessGstNoController = TextEditingController();
    priceRangeController = TextEditingController();
    setFirstTimeDiscountController = TextEditingController();
    setRegularDiscountController = TextEditingController();
    minOrderValueController = TextEditingController();
    expiryInDaysController = TextEditingController();
    noOfPeopleController = TextEditingController();
    amountController = TextEditingController();

    await fetchBusinessProfile();
    _selectedTab = initialTab;
  }

  updateFields() {
    if (profileResponse.data != null && profileResponse.data?.data != null) {
      var item = profileResponse.data!.data!;
      businessNameController =
          TextEditingController(text: item.businessName ?? "");
      businessAreaController =
          TextEditingController(text: item.businessArea ?? "");
      businessCompleteAddressController =
          TextEditingController(text: item.businessAddress ?? "");
      businessWebsiteController =
          TextEditingController(text: item.businessSiteUrl ?? "");
      businessFullNameController =
          TextEditingController(text: item.businessFullname ?? "");
      businessDesignationController =
          TextEditingController(text: item.businessDesignation ?? "");
      businessEmailController =
          TextEditingController(text: item.businessEmail ?? "");
      businessMobileController =
          TextEditingController(text: item.businessMobile ?? "");
      businessGstNoController = TextEditingController(
          text: item.gstNumber == null
              ? ''
              : item.gstNumber.toString().toUpperCase());
      setFirstTimeDiscountController = TextEditingController(
          text: item.setFirstTimeDiscount?.toString() ?? "");
      setRegularDiscountController = TextEditingController(
          text: item.setRegularDiscount?.toString() ?? "");
      if (item.setExpiry != null) {
        if (item.setExpiry == 15 ||
            item.setExpiry == 30 ||
            item.setExpiry == 365) {
          selectedExpiryDays = item.setExpiry.toString();
          showOtherField = false;
        } else {
          showOtherField = true;
          selectedExpiryDays = "Other";
          expiryInDaysController = TextEditingController(
              text: (item.setExpiry != null) ? item.setExpiry.toString() : "");
        }
      } else {
        showOtherField = false;
        selectedExpiryDays = null;
      }
      minOrderValueController =
          TextEditingController(text: item.minOrder?.toString() ?? "");
      toTimeController = TextEditingController(text: item.timeTo ?? "");
      fromTimeController = TextEditingController(text: item.timeFrom ?? "");
      priceRangeController =
          TextEditingController(text: item.pricingRangeText ?? '');
      extractPricingDetails(item.pricingRangeText);

      if (item.businessImage != null) {
        businessImage = BusinessImage(url: item.businessImage);
      } else {
        businessImage = null;
      }
      if (item.businessImage1 != null) {
        businessImage1 = BusinessImage(url: item.businessImage1);
      } else {
        businessImage1 = null;
      }
      if (item.businessImage2 != null) {
        businessImage2 = BusinessImage(url: item.businessImage2);
      } else {
        businessImage2 = null;
      }
      if (item.businessImage3 != null) {
        businessImage3 = BusinessImage(url: item.businessImage3);
      } else {
        businessImage3 = null;
      }
      if (item.businessImage4 != null) {
        businessImage4 = BusinessImage(url: item.businessImage4);
      } else {
        businessImage4 = null;
      }
      if (item.businessImage5 != null) {
        businessImage5 = BusinessImage(url: item.businessImage5);
      } else {
        businessImage5 = null;
      }
      if (item.menuCard1 != null) {
        menuImage1 = BusinessImage(url: item.menuCard1);
      } else {
        menuImage1 = null;
      }
      if (item.menuCard2 != null) {
        menuImage2 = BusinessImage(url: item.menuCard2);
      } else {
        menuImage2 = null;
      }
      if (item.menuCard3 != null) {
        menuImage3 = BusinessImage(url: item.menuCard3);
      } else {
        menuImage3 = null;
      }
      if (item.menuCard4 != null) {
        menuImage4 = BusinessImage(url: item.menuCard4);
      } else {
        menuImage4 = null;
      }
      if (item.menuCard5 != null) {
        menuImage5 = BusinessImage(url: item.menuCard5);
      } else {
        menuImage5 = null;
      }
    }
  }

  void extractPricingDetails(String? pricingText) {
    debugPrint("extractPricingDetails called with: $pricingText");

    if (pricingText == null || pricingText.isEmpty) {
      amountController = TextEditingController(text: '');
      noOfPeopleController = TextEditingController(text: '');
      return;
    }

    // Updated regex to handle formats like "₹1,000.00 for 2 people", "₹0.00 for 2 people", or "1000 for 2"
    RegExp regex = RegExp(r'₹?\s*([\d,.]+)\s*for\s*(\d+)');
    Match? match = regex.firstMatch(pricingText);

    debugPrint("Regex match result: $match");

    if (match != null) {
      // Remove commas and decimal parts from amount (keep only integer part)
      String amountStr = (match.group(1) ?? '').replaceAll(',', '');
      // Parse as double and convert to integer to remove decimal
      double? amountDouble = double.tryParse(amountStr);
      String amount =
          amountDouble != null ? amountDouble.toInt().toString() : '';
      String people = match.group(2) ?? '';

      debugPrint("Extracted amount: $amount, people: $people");

      amountController = TextEditingController(text: amount);
      noOfPeopleController = TextEditingController(text: people);
    } else {
      debugPrint("No regex match found for: $pricingText");
      amountController = TextEditingController(text: '');
      noOfPeopleController = TextEditingController(text: '');
    }
  }

  void selectTab(String tab) {
    _selectedTab = tab;
    enableEditing(false);
    notifyListeners();
  }

  void clearImages() {
    profileIndex = null;
    notifyListeners();
  }

  int numberOfImages({required bool isMenu}) {
    int imageCount = 0;
    if (isMenu) {
      if (menuImage1?.file != null || menuImage1?.url != null) {
        imageCount++;
      }
      if (menuImage2?.file != null || menuImage2?.url != null) {
        imageCount++;
      }
      if (menuImage3?.file != null || menuImage3?.url != null) {
        imageCount++;
      }
      if (menuImage4?.file != null || menuImage4?.url != null) {
        imageCount++;
      }
      if (menuImage5?.file != null || menuImage5?.url != null) {
        imageCount++;
      }
    } else {
      if (businessImage?.file != null || businessImage?.url != null) {
        imageCount++;
      }
      if (businessImage1?.file != null || businessImage1?.url != null) {
        imageCount++;
      }
      if (businessImage2?.file != null || businessImage2?.url != null) {
        imageCount++;
      }
      if (businessImage3?.file != null || businessImage3?.url != null) {
        imageCount++;
      }
      if (businessImage4?.file != null || businessImage4?.url != null) {
        imageCount++;
      }
      if (businessImage5?.file != null || businessImage5?.url != null) {
        imageCount++;
      }
    }
    return imageCount;
  }

  Future<void> fetchBusinessProfile() async {
    setResponse(ApiResponse.loading());
    var data = {"id": userId, "role_id": roleId};
    var response = await _myRepo.fetchBusinessProfileApi(data);
    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        setResponse(ApiResponse.completed(r));
        // Utils.toastMessage(r.message.toString());
        updateFields();
      },
    );
    notifyListeners();
  }

  Future<void> updateBusinessProfile() async {
    setResponse(ApiResponse.loading());
    notifyListeners();
    model.id = userId;
    model.businessArea = businessAreaController?.text;
    model.businessAddress = businessCompleteAddressController?.text;
    model.businessDesignation = businessDesignationController?.text;
    model.businessFullname = businessFullNameController?.text;
    model.businessName = businessNameController?.text;
    model.businessSiteUrl = businessWebsiteController?.text;
    model.roleId = roleId;
    model.gstNumber = businessGstNoController?.text.toUpperCase();
    model.businessMobile = businessMobileController?.text;
    model.businessEmail = businessEmailController?.text;
    model.businessImage = model.businessImage ?? "";

    var response = await _myRepo.updateBusinessProfileApi(model);
    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        var oldToken = token;
        setResponse(ApiResponse.completed(r));
        Utils.toastMessage(r.message.toString());
        enableEditing(false);
        await saveUserData(r.data!);
        token = oldToken;
        selectTab("Details");
        enableEditing(false);
        // Navigator.pop(navigatorKey.currentContext!);
        // notifyListeners();
      },
    );
    notifyListeners();
  }

  Future<void> updateBusinessDescriptionApiCall() async {
    setResponse(ApiResponse.loading());
    notifyListeners();
    String pricingRange = (amountController != null &&
            noOfPeopleController != null)
        ? "₹${amountController?.text.toCommaSeparated()} for ${noOfPeopleController?.text} people"
        : "";
    BusinessDescriptionRequestModel businessDescriptionRequestModel =
        BusinessDescriptionRequestModel(
      businessId: userId,
      token: token,
      timeFrom: fromTimeController?.text,
      timeTo: toTimeController?.text,
      pricingRangeText: pricingRange,
    );

    var response = await _myRepo
        .updateBusinessDescriptionApi(businessDescriptionRequestModel);
    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        setResponse(ApiResponse.completed(profileResponse.data));
        var oldToken = token;
        Utils.toastMessage(r.message.toString());
        enableEditing(false);
        token = oldToken;
        selectTab("Set Discount");
        enableEditing(false);
      },
    );
    notifyListeners();
  }

  Future<void> updateBusinessDiscountApiCall() async {
    setResponse(ApiResponse.loading());
    notifyListeners();

    SetDiscountRequestModel setDiscountRequestModel = SetDiscountRequestModel(
      minOrder: int.parse(minOrderValueController!.text),
      businessId: userId,
      setFirstTimeDiscount: int.parse(setFirstTimeDiscountController!.text),
      setRegularDiscount: int.parse(setRegularDiscountController!.text),
      setExpiry: (selectedExpiryDays == "Other")
          ? int.parse(expiryInDaysController!.text)
          : int.parse(selectedExpiryDays ?? '1'),
      token: token,
    );

    var response =
        await _myRepo.updateBusinessDiscountApi(setDiscountRequestModel);
    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        var oldToken = token;
        Utils.toastMessage(r.message.toString());
        enableEditing(false);
        token = oldToken;
        Navigator.pop(navigatorKey.currentContext!);
        notifyListeners();
      },
    );
    notifyListeners();
  }

  saveUserData(Data data) async {
    final SharedPreferencesService prefs = SharedPreferencesService();
    prefs.saveUserData(
      UserData(
        id: data.id,
        email: data.businessEmail,
        mobile: data.businessMobile,
        name: data.businessName,
        address: data.businessArea,
      ),
      skip: true,
    );
  }

  Future<void> getImageAttachment() async {
    File? file = await ImageHelper.pickImage();
    if (file != null) {
      model.businessImage = file.path;
      // profileResponse.data!.data!.businessImage = file.path;
      notifyListeners();
    } else {
      Utils.toastMessage("Failed to attach image");
    }
    notifyListeners();
  }

  Future<void> uploadBusinessImages() async {
    // if (numberOfImages(isMenu: false) < 3) {
    //   Utils.toastMessage("Please upload at least 4 business images.");
    //   setResponse(ApiResponse.completed(profileResponse.data));
    //   notifyListeners();
    //   return;
    // }

    if (numberOfImages(isMenu: false) == 0) {
      Utils.toastMessage("Please upload at least 1 business image.");
      setResponse(ApiResponse.completed(profileResponse.data));
      notifyListeners();
      return;
    }

    if (numberOfImages(isMenu: false) == 0) {
      // Utils.toastMessage("No business images selected to upload.");
      setResponse(ApiResponse.completed(profileResponse.data));
      notifyListeners();
      return;
    }

    setResponse(ApiResponse.loading());
    notifyListeners();
    debugPrint("Uploading business images...");
    var response = await _myRepo.uploadBusinessOrMenuImages(
      isMenu: false,
      image: businessImage?.file,
      image1: businessImage1?.file,
      image2: businessImage2?.file,
      image3: businessImage3?.file,
      image4: businessImage4?.file,
      image5: businessImage5?.file,
      businessId: userId!,
    );
    debugPrint("API Response: $response");
    response.fold(
      (l) {
        debugPrint("Error: ${l.message}");
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) {
        debugPrint("Success: ${r.message}");
        setResponse(ApiResponse.completed(profileResponse.data));
        Utils.toastMessage("Business images uploaded successfully!");
      },
    );

    notifyListeners();
  }

  Future<void> uploadMenuCardImages() async {
    if (numberOfImages(isMenu: true) == 0) {
      // Utils.toastMessage("No menu card images selected to upload.");
      setResponse(ApiResponse.completed(profileResponse.data));
      notifyListeners();
      return;
    }
    setResponse(ApiResponse.loading());
    notifyListeners();

    var response = await _myRepo.uploadBusinessOrMenuImages(
      isMenu: true,
      image1: menuImage1?.file,
      image2: menuImage2?.file,
      image3: menuImage3?.file,
      image4: menuImage4?.file,
      image5: menuImage5?.file,
      businessId: userId!,
    );
    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) {
        setResponse(ApiResponse.completed(profileResponse.data));
        Utils.toastMessage("Menu card images uploaded successfully!");
      },
    );

    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }
}

class BusinessImage {
  File? file;
  String? url;

  BusinessImage({this.file, this.url});
}
