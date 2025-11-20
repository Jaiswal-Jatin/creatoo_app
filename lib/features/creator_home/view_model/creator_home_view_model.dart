import 'package:creatoo/core.dart';
import 'package:creatoo/features/creator_home/model/creator_home_response_model.dart';
import 'package:creatoo/features/creator_profile/model/creator_profile_response.dart';

import '../repository/creator_home_repository.dart';

class CreatorHomeViewModel with ChangeNotifier {
  final CreatorHomeRepository _myRepo = CreatorHomeRepository();

  ApiResponse<CreatorHomeResponse> homeResponse = ApiResponse.loading();

  setResponse(ApiResponse<CreatorHomeResponse> response) {
    homeResponse = response;
  }

  ApiResponse<CreatorProfileResponse> profileResponse = ApiResponse.loading();

  setProfileResponse(ApiResponse<CreatorProfileResponse> response) {
    profileResponse = response;
  }

  init() async {
    await getHomeData();
    await fetchCreatorProfile();
  }

  Future<void> getHomeData() async {
    setResponse(ApiResponse.loading());
    notifyListeners();
    var data = {"user_id": userId};
    Either<AppException, CreatorHomeResponse> response =
        await _myRepo.getHomeDataApi(data);
    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message);
      },
      (r) async {
        setResponse(ApiResponse.completed(r));
        // Utils.toastMessage("${r.message}");
      },
    );
    notifyListeners();
  }

  Future<void> fetchCreatorProfile() async {
    setProfileResponse(ApiResponse.loading());
    notifyListeners();
    var data = {"id": userId, "role_id": roleId};
    var response = await _myRepo.fetchCreatorProfileApi(data);
    response.fold(
      (l) {
        setProfileResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        setProfileResponse(ApiResponse.completed(r));
        // Utils.toastMessage(r.message.toString());
      },
    );
    notifyListeners();
  }

  void navigateTo(ApplicationStatus status) async {
    await Navigator.pushNamed(
      navigatorKey.currentContext!,
      RoutesName.applicationView,
      arguments: status.name,
    );
    await getHomeData();
    notifyListeners();
  }
}
