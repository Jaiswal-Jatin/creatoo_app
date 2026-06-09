import 'package:creatoo/core.dart';
import 'package:creatoo/features/business_profile/model/business_desription_request_model.dart';
import 'package:creatoo/features/business_profile/model/business_profile_response.dart';
import 'package:creatoo/features/business_profile/model/set_discount_request_model.dart';
import 'package:creatoo/features/business_profile/repository/business_profile_repository.dart';
import 'package:creatoo/features/register_business/model/register_business_model.dart';
import 'package:creatoo/features/search/model/exclusive_offers_response_model.dart';

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
  TextEditingController? upiIdController;

  TextEditingController? priceRangeController;
  TextEditingController? setFirstTimeDiscountController;
  TextEditingController? setRegularDiscountController;
  TextEditingController? amountController;
  TextEditingController? noOfPeopleController;

  // Dynamic Category specific controllers
  TextEditingController? seatingCapacityController;
  bool isVegOnly = false;
  List<String> selectedCuisines = [];

  TextEditingController? stylistsCountController;
  String selectedGenderSupport = 'unisex';

  // Services (for both salon & turf: name, price, duration)
  List<Map<String, dynamic>> services = [];

  // Turf amenities
  List<String> selectedAmenities = [];

  String selectedTurfSize = '7v7';
  String selectedGroundType = 'Artificial Grass';
  List<String> selectedSports = [];

  // Turf options from DB
  List<String> turfCourtSizes = [];
  List<String> turfGroundTypes = [];
  List<String> turfSportOptions = [];
  List<String> turfAmenityOptions = [];
  bool isTurfOptionsLoading = false;

  // Restaurant Exclusive Offers
  List<BusinessImage> premiumOffers = [];
  List<BusinessImage> eliteOffers = [];
  List<BusinessImage> coreOffers = [];
  bool isOffersLoading = false;

  String? selectedBusinessCategory;
  List<String> businessCategories = ['restaurant', 'salon', 'turf'];
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
    upiIdController = TextEditingController();
    priceRangeController = TextEditingController();
    setFirstTimeDiscountController = TextEditingController();
    setRegularDiscountController = TextEditingController();
    noOfPeopleController = TextEditingController();
    amountController = TextEditingController();

    // Initialize category specific inputs
    seatingCapacityController = TextEditingController();
    stylistsCountController = TextEditingController();
    isVegOnly = false;
    selectedCuisines = [];
    selectedGenderSupport = 'unisex';
    services = [];
    selectedAmenities = [];
    selectedTurfSize = '7v7';
    selectedGroundType = 'Artificial Grass';
    selectedSports = [];

    await fetchBusinessProfile();
    await fetchTurfOptions();
    await fetchMyExclusiveOffers();
    _selectedTab = initialTab;
  }

  updateFields() {
    if (profileResponse.data != null && profileResponse.data?.data != null) {
      var item = profileResponse.data!.data!;
      businessNameController?.text = item.businessName ?? '';
      businessAreaController?.text = item.businessArea ?? '';
      businessCompleteAddressController?.text = item.businessAddress ?? '';
      businessWebsiteController?.text = item.businessSiteUrl ?? '';
      businessFullNameController?.text = item.businessFullname ?? '';
      businessDesignationController?.text = item.businessDesignation ?? '';
      businessEmailController?.text = item.businessEmail ?? '';
      businessMobileController?.text = item.businessMobile ?? '';
      businessGstNoController?.text =
          item.gstNumber == null ? '' : item.gstNumber.toString().toUpperCase();
      upiIdController?.text = item.upiId ?? '';
      selectedBusinessCategory = item.businessCategory ?? 'restaurant';
      setFirstTimeDiscountController?.text =
          item.setFirstTimeDiscount?.toString() ?? '';
      setRegularDiscountController?.text =
          item.setRegularDiscount?.toString() ?? '';
      toTimeController?.text = item.timeTo ?? '';
      fromTimeController?.text = item.timeFrom ?? '';
      priceRangeController?.text = item.pricingRangeText ?? '';
      extractPricingDetails(item.pricingRangeText);

      // Populate category-specific inputs from database
      if (item.categoryAttributes != null) {
        final attrs = item.categoryAttributes!;
        seatingCapacityController?.text =
            attrs['seating_capacity']?.toString() ?? '';
        isVegOnly = attrs['is_veg_only'] == true;
        selectedCuisines = attrs['cuisine_type'] != null
            ? List<String>.from(attrs['cuisine_type'])
            : [];

        selectedGenderSupport = attrs['gender_support']?.toString() ?? "unisex";
        if (attrs['stylists'] != null && attrs['stylists'] is List) {
          stylistsCountController?.text =
              (attrs['stylists'] as List).length.toString();
        } else {
          stylistsCountController?.text = '';
        }
        services = attrs['services'] != null
            ? List<Map<String, dynamic>>.from(attrs['services'])
            : [];

        selectedTurfSize = attrs['turf_size']?.toString() ?? "7v7";
        selectedGroundType =
            attrs['ground_type']?.toString() ?? "Artificial Grass";
        selectedSports = attrs['sport_types'] != null
            ? List<String>.from(attrs['sport_types'])
            : [];
        selectedAmenities = attrs['amenities'] != null
            ? List<String>.from(attrs['amenities'])
            : [];
        services = attrs['services'] != null
            ? List<Map<String, dynamic>>.from(attrs['services'])
            : [];
        // Merge old-format sport_types/amenities into services for backward compatibility
        if (attrs['sport_types'] != null) {
          for (final s in List<String>.from(attrs['sport_types'])) {
            if (!services.any((svc) => svc['name'] == s)) {
              services.add({'name': s, 'price': 0, 'duration_minutes': 60});
            }
            if (!selectedSports.contains(s)) {
              selectedSports.add(s);
            }
          }
        }
        if (attrs['amenities'] != null) {
          for (final a in List<String>.from(attrs['amenities'])) {
            if (!services.any((svc) => svc['name'] == a)) {
              services.add({'name': a, 'price': 0, 'duration_minutes': 0});
            }
            if (!selectedAmenities.contains(a)) {
              selectedAmenities.add(a);
            }
          }
        }
      } else {
        seatingCapacityController = TextEditingController();
        stylistsCountController = TextEditingController();
        isVegOnly = false;
        selectedCuisines = [];
        selectedGenderSupport = 'unisex';
        services = [];
        selectedAmenities = [];
        selectedTurfSize = '7v7';
        selectedGroundType = 'Artificial Grass';
        selectedSports = [];
      }

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

  void updateBusinessCategory(String value) {
    selectedBusinessCategory = value;
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
    model.businessCategory = selectedBusinessCategory;
    model.businessImage = model.businessImage ?? "";
    model.upiId = upiIdController?.text;

    // Map dynamic category attributes
    if (selectedBusinessCategory == 'restaurant') {
      model.categoryAttributes = {
        'cuisine_type': selectedCuisines,
        'is_veg_only': isVegOnly,
        'seating_capacity':
            seatingCapacityController?.text.trim().isNotEmpty == true
                ? int.tryParse(seatingCapacityController!.text.trim())
                : null,
      };
    } else if (selectedBusinessCategory == 'salon') {
      final attrs = <String, dynamic>{'gender_support': selectedGenderSupport};
      if (stylistsCountController?.text.trim().isNotEmpty == true) {
        attrs['stylists'] = List.generate(
          int.tryParse(stylistsCountController!.text.trim()) ?? 1,
          (i) => "Stylist ${i + 1}",
        );
      }
      if (services.isNotEmpty) {
        attrs['services'] = services;
      }
      model.categoryAttributes = attrs;
    } else if (selectedBusinessCategory == 'turf') {
      // Synchronize selectedSports and selectedAmenities with services
      final sportTypes = services
          .where((s) => turfSportOptions.contains(s['name']))
          .map((s) => s['name'] as String)
          .toList();
      final amenitiesList = services
          .where((s) => turfAmenityOptions.contains(s['name']))
          .map((s) => s['name'] as String)
          .toList();

      final attrs = <String, dynamic>{
        'turf_size': selectedTurfSize,
        'ground_type': selectedGroundType,
        'sport_types': sportTypes.isNotEmpty ? sportTypes : selectedSports,
        'amenities':
            amenitiesList.isNotEmpty ? amenitiesList : selectedAmenities,
      };
      if (services.isNotEmpty) {
        attrs['services'] = services;
      }
      model.categoryAttributes = attrs;
    } else {
      model.categoryAttributes = null;
    }

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
      businessId: userId,
      setFirstTimeDiscount:
          int.tryParse(setFirstTimeDiscountController?.text ?? '') ?? 0,
      setRegularDiscount:
          int.tryParse(setRegularDiscountController?.text ?? '') ?? 0,
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
        await fetchBusinessProfile();
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
        roleId: data.roleId ?? roleId,
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

  void clearImage(int index, {required bool isMenuCard}) {
    if (isMenuCard) {
      switch (index) {
        case 0:
          menuImage1 = null;
          break;
        case 1:
          menuImage2 = null;
          break;
        case 2:
          menuImage3 = null;
          break;
        case 3:
          menuImage4 = null;
          break;
        case 4:
          menuImage5 = null;
          break;
      }
    } else {
      switch (index) {
        case 0:
          businessImage = null;
          break;
        case 1:
          businessImage1 = null;
          break;
        case 2:
          businessImage2 = null;
          break;
        case 3:
          businessImage3 = null;
          break;
        case 4:
          businessImage4 = null;
          break;
        case 5:
          businessImage5 = null;
          break;
      }
    }
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

  Future<void> fetchTurfOptions() async {
    isTurfOptionsLoading = true;
    notifyListeners();
    try {
      final response = await _myRepo.fetchTurfOptionsApi();
      response.fold(
        (l) => debugPrint("Failed to fetch turf options: ${l.message}"),
        (r) {
          if (r.data != null) {
            turfCourtSizes = r.data!['court_size'] ?? [];
            turfGroundTypes = r.data!['ground_type'] ?? [];
            turfSportOptions = r.data!['sport'] ?? [];
            turfAmenityOptions = r.data!['amenity'] ?? [];
          }
        },
      );
    } catch (e) {
      debugPrint("Error fetching turf options: $e");
    }
    isTurfOptionsLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyExclusiveOffers() async {
    isOffersLoading = true;
    notifyListeners();
    try {
      final response = await _myRepo.fetchMyExclusiveOffersApi();
      response.fold(
        (l) {
          debugPrint("Failed to fetch exclusive offers: ${l.message}");
          premiumOffers = [];
          eliteOffers = [];
          coreOffers = [];
        },
        (r) {
          if (r.data != null) {
            premiumOffers = (r.data!.premiumOffers ?? [])
                .map((url) => BusinessImage(url: url))
                .toList();
            eliteOffers = (r.data!.eliteOffers ?? [])
                .map((url) => BusinessImage(url: url))
                .toList();
            coreOffers = (r.data!.coreOffers ?? [])
                .map((url) => BusinessImage(url: url))
                .toList();
          }
        },
      );
    } catch (e) {
      debugPrint("Error fetching exclusive offers: $e");
    }
    isOffersLoading = false;
    notifyListeners();
  }

  Future<void> saveExclusiveOffers() async {
    isOffersLoading = true;
    notifyListeners();

    List<Map<String, String>> files = [];
    List<String> keepPremium = [];
    List<String> keepElite = [];
    List<String> keepCore = [];

    // Premium
    for (final img in premiumOffers) {
      if (img.url != null) {
        keepPremium.add(img.url!);
      } else if (img.file != null) {
        files.add({
          "fieldName": "premium",
          "filePath": img.file!.path,
        });
      }
    }

    // Elite
    for (final img in eliteOffers) {
      if (img.url != null) {
        keepElite.add(img.url!);
      } else if (img.file != null) {
        files.add({
          "fieldName": "elite",
          "filePath": img.file!.path,
        });
      }
    }

    // Core
    for (final img in coreOffers) {
      if (img.url != null) {
        keepCore.add(img.url!);
      } else if (img.file != null) {
        files.add({
          "fieldName": "core",
          "filePath": img.file!.path,
        });
      }
    }

    try {
      final response = await _myRepo.saveExclusiveOffersApi(
        files: files,
        keepPremium: keepPremium,
        keepElite: keepElite,
        keepCore: keepCore,
      );

      response.fold(
        (l) {
          isOffersLoading = false;
          notifyListeners();
          Utils.toastMessage("Failed to save offers: ${l.message}");
        },
        (r) async {
          Utils.toastMessage(r.message ?? "Offers saved successfully!");
          await fetchMyExclusiveOffers();
          Navigator.pop(navigatorKey.currentContext!);
        },
      );
    } catch (e) {
      isOffersLoading = false;
      notifyListeners();
      Utils.toastMessage("Error saving offers: $e");
    }
  }
}

class BusinessImage {
  File? file;
  String? url;

  BusinessImage({this.file, this.url});
}
