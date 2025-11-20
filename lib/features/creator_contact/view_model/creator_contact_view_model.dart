import 'package:creatoo/core.dart';
import 'package:creatoo/features/creator_contact/repository/creator_contact_repository.dart';

import '../model/creator_contact_response.dart';

class CreatorContactViewModel with ChangeNotifier {
  final CreatorContactRepository _myRepo = CreatorContactRepository();

  ApiResponse<CreatorContactResponse> apiResponse = ApiResponse.loading();

  setResponse(ApiResponse<CreatorContactResponse> response) {
    apiResponse = response;
  }

  Future<void> fetchCreatorContactList(int postId) async {
    setResponse(ApiResponse.loading());
    // notifyListeners();
    var data = {"post_id": postId};
    Either<AppException, CreatorContactResponse> response =
        await _myRepo.getCreatorContactApi(data);
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
}
