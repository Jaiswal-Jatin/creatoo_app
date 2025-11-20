import 'package:creatoo/core.dart';
import 'package:creatoo/features/business_profile/model/business_profile_response.dart';
import 'package:creatoo/features/business_profile/repository/business_profile_repository.dart';

class BusinessProfileViewModel with ChangeNotifier {
  final BusinessProfileRepository _myRepo = BusinessProfileRepository();

  ApiResponse<BusinessProfileResponse> profileResponse = ApiResponse.loading();

  setResponse(ApiResponse<BusinessProfileResponse> response) {
    profileResponse = response;
  }

  init() async {
    await fetchBusinessProfile();
  }

  Future<void> fetchBusinessProfile() async {
    setResponse(ApiResponse.loading());
    notifyListeners();
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
      },
    );
    notifyListeners();
  }
}
