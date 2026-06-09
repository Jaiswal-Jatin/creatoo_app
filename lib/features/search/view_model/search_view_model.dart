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

  final Map<String, List<BusinessSearchData>> _categoryCache = {};
  final Map<String, Future<void>> _categoryPreloadFutures = {};

  int currentPage = 1;
  int totalPages = 1;
  bool isLoadingMore = false;
  int userRole = 0;
  int currentSelection = 0;
  String? selectedCategory; // 'restaurant', 'salon', 'turf', or null for all

  late TextEditingController searchController = TextEditingController();
  BusinessDescription? businessDescription;
  ExclusiveOffersData? exclusiveOffersData;

  Future<void> preloadCategory(String category) async {
    if (_categoryCache.containsKey(category)) return;
    if (_categoryPreloadFutures.containsKey(category)) {
      await _categoryPreloadFutures[category];
      return;
    }
    final future = _doPreload(category);
    _categoryPreloadFutures[category] = future;
    await future;
  }

  Future<void> _doPreload(String category) async {
    var data = {
      "role_id": Constants.businessUser,
      "per_page": 30,
      "page": 1,
      "business_category": category,
    };
    var response = await _myRepo.searchBusinessUserApi(data);
    response.fold(
      (l) {
        print("Preload $category error: ${l.message}");
      },
      (r) {
        final active = r.data?.where((b) => b.isActive == 1).toList() ?? [];
        _categoryCache[category] = active;
        print("Preloaded $category: ${active.length} businesses");
      },
    );
  }

  Future<List<BusinessSearchData>?> getCachedCategoryData(String category) async {
    if (_categoryCache.containsKey(category)) return _categoryCache[category];
    if (_categoryPreloadFutures.containsKey(category)) {
      await _categoryPreloadFutures[category];
      return _categoryCache[category];
    }
    return null;
  }

  ApiResponse<SearchCreatorResponse> creatorResponse = ApiResponse.initial();
  ApiResponse<ExclusiveOffersResponseModel> exclusiveOffersApiResponse =
      ApiResponse.initial();

  setExclusiveOffersResponse(
      ApiResponse<ExclusiveOffersResponseModel> response) {
    exclusiveOffersApiResponse = response;
  }

  setCreatorResponse(ApiResponse<SearchCreatorResponse> response) {
    creatorResponse = response;
  }

  ApiResponse<SearchBusinessResponse> searchResponse = ApiResponse.initial();

  setBusinessResponse(ApiResponse<SearchBusinessResponse> response) {
    searchResponse = response;
  }

  ApiResponse<BusinessDetailsResponseModel> businessDetailsResponse =
      ApiResponse.initial();

  setBusinessDetailsResponse(
      ApiResponse<BusinessDetailsResponseModel> response) {
    businessDetailsResponse = response;
  }

  init(role, {String? category}) async {
    userRole = role;
    searchController = TextEditingController();
    currentPage = 0;
    totalPages = 1;
    businessSearchList?.clear();
    businessDescription = null;
    exclusiveOffersData = null;
    if (category != null) {
      selectedCategory = category;
    }
    await searchBusinessUser(); // Initial load of businesses
  }

  /// Set category filter and reload
  Future<void> setCategoryFilter(String? category) async {
    if (selectedCategory == category) return;
    selectedCategory = category;
    currentPage = 0;
    totalPages = 1;
    businessSearchList?.clear();
    notifyListeners();
    await searchBusinessUser();
  }

  void restoreOriginalList() async {
    // Made async to await searchBusinessUser
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
    if (searchQuery.trim().isEmpty) {
      // If search query is empty, load all businesses
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
      if (selectedCategory != null) "business_category": selectedCategory,
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
        print(
            "SearchViewModel: Total businesses from API: ${r.data?.length ?? 0}");
        r.data?.forEach((b) {
          print(
              "Business: ${b.businessName}, isActive: ${b.isActive}, type: ${b.isActive.runtimeType}");
        });
        setBusinessResponse(ApiResponse.completed(r));

        // Only show businesses where is_active: true (isActive == 1)
        final activeBusinesses =
            r.data?.where((b) => b.isActive == 1).toList() ?? [];
        print(
            "SearchViewModel: Active businesses after filter: ${activeBusinesses.length}");

        if (currentPage == 0) {
          businessSearchList = activeBusinesses;
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
      if (selectedCategory != null) "business_category": selectedCategory,
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
        final activeBusinesses =
            r.data?.where((b) => b.isActive == 1).toList() ?? [];
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
      "key": searchQuery,
      if (selectedCategory != null) "business_category": selectedCategory,
    };

    // Log the API URL for debugging purposes
    log("Calling API: ${AppUrl.searchBusinessAndCreator} with body: $data"); // Corrected AppUrl

    setBusinessResponse(ApiResponse.loading()); // Uncommented and activated
    notifyListeners(); // Notify listeners to show loading state
    var response = await _myRepo.searchBusinessUserByNameApi(
        data); // Changed to use correct repository method
    response.fold((l) {
      print("SearchViewModel: searchBusinessUserByNameApi error: ${l.message}");
      setBusinessResponse(ApiResponse.error(l.message));
      Utils.toastMessage(l.message);
    }, (r) {
      print("SearchViewModel: searchBusinessUserByNameApi completed");
      setBusinessResponse(ApiResponse.completed(r)); // Set completed status
      // Only show businesses where is_active: true (isActive == 1)
      final activeBusinesses =
          r.data?.where((b) => b.isActive == 1).toList() ?? [];
      businessSearchList =
          activeBusinesses; // Update businessSearchList with active search results

      currentPage = 1; // Reset current page for search results
      totalPages = r.pagination?.lastPage ?? 1; // Update total pages
    });
    notifyListeners(); // Notify listeners for state update
  }

  Future<void> getBusinessDetailsApi({required int id}) async {
    print("📊 [BUSINESS_DETAILS] Fetching business details for ID: $id");
    businessDescription = null;
    setBusinessDetailsResponse(ApiResponse.loading());
    var data = {
      "role_id": Constants.businessUser,
      "id": id
    }; // Removed "token": token
    var response = await _myRepo.getBusinessDetails(data);
    response.fold(
      (l) {
        print(
            "❌ [BUSINESS_DETAILS] Error fetching business details: ${l.message}");
        setBusinessDetailsResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) {
        print("✅ [BUSINESS_DETAILS] Business details fetched successfully");
        print("📊 [BUSINESS_DETAILS] Business: ${r.data?.businessName}");
        print(
            "📊 [BUSINESS_DETAILS] Has associates: ${(r.data?.associates?.isNotEmpty ?? false)}");
        if (r.data?.associates != null && r.data!.associates!.isNotEmpty) {
          print(
              "📊 [BUSINESS_DETAILS] Associates count: ${r.data!.associates!.length}");
          for (var i = 0; i < r.data!.associates!.length; i++) {
            print(
                "📊 [BUSINESS_DETAILS] Associate $i: ${r.data!.associates![i].businessName} (ID: ${r.data!.associates![i].id})");
          }
        }
        setBusinessDetailsResponse(ApiResponse.completed(r));
        businessDescription = r.data;
      },
    );
    notifyListeners();
  }

  Future<void> getExclusiveOffersApi({required int businessId}) async {
    exclusiveOffersData = null;
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
