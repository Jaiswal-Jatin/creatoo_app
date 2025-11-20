import 'package:creatoo/core.dart';
import 'package:creatoo/features/shortlist/model/shortlist_model.dart';
import 'package:creatoo/features/shortlist/repository/shortlist_repository.dart';

import '../model/post_application_response.dart';

class ShortlistViewModel with ChangeNotifier {
  final ShortlistRepository _myRepo = ShortlistRepository();
  int? postId;
  bool isLoading = false;

  ApiResponse<PostApplicationResponse> shortlistResponse =
      ApiResponse.loading();

  setResponse(ApiResponse<PostApplicationResponse> response) {
    shortlistResponse = response;
  }

  ApiResponse<BaseResponse> cartResponse =
      ApiResponse.initial();
  setCartResponse(ApiResponse<BaseResponse> response) {
    cartResponse = response;
  }

  init(int id) async {
    postId = id;
    await getPostApplicationList();
  }

  updateCart(int index, bool value) async {
    await addCreatorToCart(shortlistResponse.data!.data![index].id!);
    shortlistResponse.data!.data![index].isCart = value ? 1 : 0;
    notifyListeners();
  }

  Future<void> getPostApplicationList() async {
    setResponse(ApiResponse.loading());
    var data = {"post_id": postId};
    var response = await _myRepo.getPostApplicationListApi(data);
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

  Future<void> addCreatorToCart(int creatorId) async {
    setCartResponse(ApiResponse.loading());
    notifyListeners();
    var data = {"creator_id": creatorId, "post_id": postId};
    var response = await _myRepo.addCreatorToCartApi(data);
    response.fold((l) {
      setCartResponse(ApiResponse.error(l.message));
      Utils.snackBar(l.message.toString(), result: Result.error);
    }, (r) async {
      setCartResponse(ApiResponse.completed(r));
      Utils.snackBar(r.message.toString(), result: Result.success);
    });
    notifyListeners();
  }

  Future<void> shortlistCreator() async {
    isLoading = true;
    notifyListeners();
    var shortlist = shortlistResponse.data!.data!
        .where((element) => element.isCart == 1)
        .toList();
    List<String> creatorIds = [];
    shortlist.forEach(
      (element) {
        creatorIds.add(element.id!.toString());
      },
    );

    ShortlistModel model =
        ShortlistModel(postId: postId, creatorIds: creatorIds);

    var response = await _myRepo.shortlistCreatorForPostApi(model.toJson());
    response.fold(
      (l) {
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        // Navigator.pushNamedAndRemoveUntil(navigatorKey.currentContext!,
        //     RoutesName.successView, (route) => false);
        // Utils.toastMessage(r.message.toString());
        AppBottomSheet.showBottomSheet();
      },
    );
    isLoading = false;
    notifyListeners();
  }
}
