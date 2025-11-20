import '../../../core.dart';
import '../model/creator_profile_response.dart';
import '../repository/creator_profile_repository.dart';

class CreatorProfileDetailViewModel with ChangeNotifier {
  final CreatorProfileRepository _myRepo = CreatorProfileRepository();
  ApiResponse<CreatorProfileResponse> profileResponse = ApiResponse.initial();
  bool isLoading = false;

  setResponse(ApiResponse<CreatorProfileResponse> response) {
    profileResponse = response;
  }

  int callInstaApi = 0;
  int creatorId = -1;

  init(id) async {
    creatorId = id;
    await fetchUpdatedProfile();
    await fetchProfile();
  }

  Future<void> fetchProfile() async {
    setResponse(ApiResponse.loading());
    notifyListeners();
    var data = {
      "id": creatorId != -1 ? creatorId : userId,
      "role_id": creatorId != -1 ? Constants.creatorUser : roleId,
      "callInstaApi": callInstaApi
    };
    var response = await _myRepo.fetchCreatorProfileApi(data);
    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        // r.data!.instagramVerificationStatus = 1;
        setResponse(ApiResponse.completed(r));
        SharedPreferencesService _prefs = SharedPreferencesService();
        await _prefs.saveProfileUpdatedDate(r.data!.updatedAt.toString());
      },
    );
    notifyListeners();
  }

  Future<void> fetchUpdatedProfile() async {
    SharedPreferencesService _prefs = SharedPreferencesService();
    String? value = await _prefs.getProfileUpdatedDate();
    if (value == null || value == "null") {
      callInstaApi = 0;
    } else {
      var updatedAt = DateTimeHelper.convertStringToDatetime(value);
      Duration difference = DateTime.now().difference(updatedAt);
      print(difference.inDays);
      if (difference.inDays > 30) {
        callInstaApi = 1;
      }
    }
  }

  Future<void> submitInstagramVerification(String username, String filePath) async {
    isLoading = true;
    notifyListeners();
    var data = {"mobile": user!.mobile, "username": username};
    var response = await _myRepo.submitInstagramVerificationApi(data, filePath);
    response.fold(
      (l) {
        Utils.toastMessage(l.message);
      },
      (r) async {
        await fetchProfile();
        Utils.toastMessage(r.message);
      },
    );
    isLoading = false;
    notifyListeners();
  }
}
