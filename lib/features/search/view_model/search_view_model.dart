import 'dart:async';

import 'package:creatoo/features/search/model/business_details_response_model.dart';
import 'package:creatoo/features/search/model/exclusive_offers_response_model.dart';

import '../../../core.dart';
import '../model/search_business_model.dart';
import '../model/search_creator_model.dart';
import '../repository/search_repository.dart';
import '../widgets/search_business_view.dart';
import '../widgets/search_creator_view.dart';

class SearchViewModel with ChangeNotifier {
  final SearchRepository _myRepo = SearchRepository();
  final List<Widget> widgetOptions = <Widget>[
    SearchCreatorView(),
    SearchBusinessView(),
  ];
  List<BusinessSearchData>? businessSearchList = [];
  List<BusinessSearchData>? _originalBusinessList = [];
  int currentPage = 1;
  int totalPages = 1;
  bool isLoadingMore = false;
  int userRole = 0;
  int currentSelection = 0;
  Timer? _debounce;
  late TextEditingController searchController = TextEditingController();
  BusinessDescription? businessDescription;
  ExclusiveOffersData? exclusiveOffersData;

  ApiResponse<SearchCreatorResponse> creatorResponse = ApiResponse.initial();
  ApiResponse<ExclusiveOffersResponseModel> exclusiveOffersApiResponse = ApiResponse.initial();

  setExclusiveOffersResponse(ApiResponse<ExclusiveOffersResponseModel> response) {
    exclusiveOffersApiResponse = response;
  }

  setCreatorResponse(ApiResponse<SearchCreatorResponse> response) {
    creatorResponse = response;
  }

  ApiResponse<SearchBusinessResponse> searchResponse = ApiResponse.initial();

  setBusinessResponse(ApiResponse<SearchBusinessResponse> response) {
    searchResponse = response;
  }

  ApiResponse<BusinessDetailsResponseModel> businessDetailsResponse = ApiResponse.initial();

  setBusinessDetailsResponse(ApiResponse<BusinessDetailsResponseModel> response) {
    businessDetailsResponse = response;
  }

  init(role) async {
    userRole = role;
    searchController = TextEditingController();
    // Removed searchController.addListener to prevent API calls on text change
    currentPage = 0;
    totalPages = 1;
    businessSearchList?.clear();
    await searchBusinessUser(); // Initial load of businesses
  }

  void restoreOriginalList() async { // Made async to await searchBusinessUser
    searchController.clear();
    await searchBusinessUser(); // Reload all businesses
    notifyListeners();
  }

  @override
  void dispose() {
    // _debounce?.cancel(); // Removed _debounce cancellation
    searchController.dispose();
    super.dispose();
  }

  bool get hasMoreData => currentPage == 0 || currentPage < totalPages;

  Future<void> searchUser({String searchQuery = ""}) async {
    if (searchQuery.trim().isEmpty) { // If search query is empty, load all businesses
      await searchBusinessUser();
    } else if (userRole == Constants.businessUser) {
      await searchBusinessUserByNameApi(searchQuery: searchQuery);
    } else {
      // await searchCreatorUserByNameApi(searchQuery: searchQuery);
    }
  }

  Future<void> searchBusinessUser() async {
    if (!hasMoreData) return;

    setBusinessResponse(ApiResponse.loading());
    // Change to use the new API for fetching business list
    var data = {
      "role_id": userRole,
      "per_page": 30,
      "page": currentPage + 1,
    };
    var response = await _myRepo.searchBusinessUserApi(data);

    response.fold(
      (l) {
        print("SearchViewModel: searchBusinessUser error: ${l.message}");
        setBusinessResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) {
        print("SearchViewModel: searchBusinessUser completed");
        print("SearchViewModel: Total businesses from API: ${r.data?.length ?? 0}");
        r.data?.forEach((b) {
          print("Business: ${b.businessName}, isActive: ${b.isActive}, type: ${b.isActive.runtimeType}");
        });
        setBusinessResponse(ApiResponse.completed(r));

        // Only show businesses where is_active: true (isActive == 1)
        final activeBusinesses = r.data?.where((b) => b.isActive == 1).toList() ?? [];
        print("SearchViewModel: Active businesses after filter: ${activeBusinesses.length}");

        if (currentPage == 0) {
          businessSearchList = activeBusinesses;
          _originalBusinessList = List.from(activeBusinesses);
        } else {
          businessSearchList?.addAll(activeBusinesses);
        }

        totalPages = r.pagination?.lastPage ?? 1;
        currentPage++;
        notifyListeners();
      },
    );
  }

  Future<void> loadMoreBusinessUsers() async {
    if (isLoadingMore || !hasMoreData) return;

    isLoadingMore = true;
    notifyListeners();

    var data = {
      "role_id": userRole,
      "per_page": 30,
      "page": currentPage + 1,
    };
    var response = await _myRepo.searchBusinessUserApi(data);

    response.fold(
      (l) {
        print("SearchViewModel: loadMoreBusinessUsers error: ${l.message}");
        isLoadingMore = false;
        Utils.toastMessage(l.message.toString());
        notifyListeners();
      },
      (r) {
        print("SearchViewModel: loadMoreBusinessUsers completed");
        // Only show businesses where is_active: true (isActive == 1)
        final activeBusinesses = r.data?.where((b) => b.isActive == 1).toList() ?? [];
        if (activeBusinesses.isNotEmpty) {
          businessSearchList?.addAll(activeBusinesses);
          currentPage++;
        }

        totalPages = r.pagination?.lastPage ?? totalPages;
        isLoadingMore = false;
        notifyListeners();
      },
    );
  }

  Future<void> searchBusinessUserByNameApi({String searchQuery = ""}) async {
    var data = {
      "role_id": userRole,
      "per_page": 30,
      "page": 1,
      "key": searchQuery, // Corrected typo from "k,ey" to "key"
    };

    // Log the API URL for debugging purposes
    log("Calling API: ${AppUrl.searchBusinessAndCreator} with body: $data"); // Corrected AppUrl

    setBusinessResponse(ApiResponse.loading()); // Uncommented and activated
    notifyListeners(); // Notify listeners to show loading state
    var response = await _myRepo.searchBusinessUserByNameApi(data); // Changed to use correct repository method
    response.fold((l) {
      print("SearchViewModel: searchBusinessUserByNameApi error: ${l.message}");
      setBusinessResponse(ApiResponse.error(l.message));
      Utils.toastMessage(l.message);
    }, (r) {
      print("SearchViewModel: searchBusinessUserByNameApi completed");
      setBusinessResponse(ApiResponse.completed(r)); // Set completed status
      // Only show businesses where is_active: true (isActive == 1)
      final activeBusinesses = r.data?.where((b) => b.isActive == 1).toList() ?? [];
      businessSearchList = activeBusinesses; // Update businessSearchList with active search results
      _originalBusinessList = List.from(activeBusinesses); // Update original list
      currentPage = 1; // Reset current page for search results
      totalPages = r.pagination?.lastPage ?? 1; // Update total pages
    });
    notifyListeners(); // Notify listeners for state update
  }

  Future<void> getBusinessDetailsApi({required int id}) async {
    setBusinessDetailsResponse(ApiResponse.loading());
    var data = {"role_id": Constants.businessUser, "id": id}; // Removed "token": token
    var response = await _myRepo.getBusinessDetails(data);
    response.fold(
      (l) {
        setBusinessDetailsResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) {
        setBusinessDetailsResponse(ApiResponse.completed(r));
        businessDescription = r.data;
      },
    );
    notifyListeners();
  }

  Future<void> getExclusiveOffersApi({required int businessId}) async {
    setExclusiveOffersResponse(ApiResponse.loading());
    var response = await _myRepo.getExclusiveOffers(businessId);
    response.fold(
      (l) {
        setExclusiveOffersResponse(ApiResponse.error(l.message));
        // Removed toast message as per requirement to hide 'Exclusive offer not found' message
      },
      (r) {
        setExclusiveOffersResponse(ApiResponse.completed(r));
        exclusiveOffersData = r.data;
      },
    );
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }
}
