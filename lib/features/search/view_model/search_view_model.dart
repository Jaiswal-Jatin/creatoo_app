import 'dart:async';

import 'package:creatoo/features/search/model/business_details_response_model.dart';

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

  ApiResponse<SearchCreatorResponse> creatorResponse = ApiResponse.initial();

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
    searchController.addListener(() {
      onSearchTextChanged(searchController.text);
    });
    currentPage = 0;
    totalPages = 1;
    businessSearchList?.clear();
    await searchBusinessUser();
  }

  void onSearchTextChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.trim().isEmpty) {
        restoreOriginalList();
      } else {
        searchUser(searchQuery: query);
      }
    });
  }

  void restoreOriginalList() {
    searchController.clear();
    businessSearchList = List.from(_originalBusinessList ?? []);
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  bool get hasMoreData => currentPage == 0 || currentPage < totalPages;

  Future<void> searchUser({String searchQuery = ""}) async {
    if (userRole == Constants.businessUser) {
      await searchBusinessUserByNameApi(searchQuery: searchQuery);
    } else {
      // await searchCreatorUserByNameApi(searchQuery: searchQuery);
    }
  }

  Future<void> searchBusinessUser() async {
    if (!hasMoreData) return;

    setBusinessResponse(ApiResponse.loading());
    var data = {"role_id": userRole, "page": currentPage + 1};
    var response = await _myRepo.searchBusinessUserApi(data);

    response.fold(
      (l) {
        setBusinessResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) {
        setBusinessResponse(ApiResponse.completed(r));

        if (currentPage == 0) {
          businessSearchList = r.data;
          _originalBusinessList = List.from(r.data ?? []);
        } else {
          businessSearchList?.addAll(r.data ?? []);
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

    var data = {"role_id": userRole, "page": currentPage + 1};
    var response = await _myRepo.searchBusinessUserApi(data);

    response.fold(
      (l) {
        isLoadingMore = false;
        Utils.toastMessage(l.message.toString());
        notifyListeners();
      },
      (r) {
        if (r.data != null && r.data!.isNotEmpty) {
          businessSearchList?.addAll(r.data ?? []);
          currentPage++;
        }

        totalPages = r.pagination?.lastPage ?? totalPages;
        isLoadingMore = false;
        notifyListeners();
      },
    );
  }

  Future<void> searchBusinessUserByNameApi({String searchQuery = ""}) async {
    var data = {"key": "$searchQuery", "role_id": userRole};
    // setBusinessResponse(ApiResponse.loading());
    // notifyListeners();
    var response = await _myRepo.searchBusinessUserByNameApi(data);
    response.fold((l) {
      setBusinessResponse(ApiResponse.error(l.message));
      Utils.toastMessage(l.message);
    }, (r) {
      //setBusinessResponse(ApiResponse.completed(r));
      businessSearchList = r.data;
    });
    notifyListeners();
  }

  Future<void> getBusinessDetailsApi({required int id}) async {
    setBusinessDetailsResponse(ApiResponse.loading());
    var data = {"role_id": Constants.businessUser, "id": id, "token": token};
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

  void notify() {
    notifyListeners();
  }
}
