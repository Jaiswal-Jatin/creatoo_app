import 'package:creatoo/core.dart';
import 'package:creatoo/features/post/model/view_my_post_response.dart';

import '../repository/post_repository.dart';

class PostViewModel with ChangeNotifier {
  final PostRepository _myRepo = PostRepository();
  bool isLoading = false;

  ApiResponse<ViewMyPostResponse> postResponse = ApiResponse.initial();

  setResponse(ApiResponse<ViewMyPostResponse> response) {
    postResponse = response;
  }

  init() async {
    await viewMyPost();
  }

  Future<void> viewMyPost() async {
    setResponse(ApiResponse.loading());
    // notifyListeners();
    var data = {"user_id": userId};
    var response = await _myRepo.getMyPostApi(data);
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

  Future<void> releasePaymentToCreator(int postId) async {
    // setResponse(ApiResponse.loading());
    isLoading = true;
    notifyListeners();
    var data = {"post_id": postId};
    var response = await _myRepo.releasePaymentToCreatorApi(data);
    response.fold(
      (l) {
        // setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        // setResponse(ApiResponse.completed(r));
        Utils.toastMessage(r.message.toString());
        await viewMyPost();
      },
    );
    isLoading = false;
    notifyListeners();
  }
}
