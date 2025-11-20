import 'package:creatoo/core.dart';
import 'package:creatoo/features/post_detail/repository/post_detail_repository.dart';

import '../model/post_detail_response.dart';

class PostDetailViewModel with ChangeNotifier {
  final PostDetailRepository _myRepo = PostDetailRepository();

  int? radioValue;
  int creatorRequired = 1;
  bool isValidating = false;
  List<WorkMode> radioValues = WorkMode.values;
  late TextEditingController postExpiryController;
  late TextEditingController postNameController;
  late TextEditingController postDescriptionController;

  late TextEditingController postMinInstaController;
  late TextEditingController postDeliverablesController;
  late TextEditingController postAmountController;

  late TextEditingController postDurationController;

  ApiResponse<BaseResponse> interestResponse = ApiResponse.initial();

  setInterestResponse(ApiResponse<BaseResponse> response) {
    interestResponse = response;
  }

  ApiResponse<PostDetailResponse> opportunityResponse = ApiResponse.initial();

  setOpportunityResponse(ApiResponse<PostDetailResponse> response) {
    opportunityResponse = response;
  }

  init(postId) async {
    await getOpportunityDetails(postId);
  }

  Future<void> addInterestToPost(int postId) async {
    var data = {"user_id": userId, "post_id": postId};
    setInterestResponse(ApiResponse.loading());
    notifyListeners();
    var response = await _myRepo.addInterestToPostApi(data);
    response.fold(
      (l) {
        setInterestResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message);
      },
      (r) {
        setInterestResponse(ApiResponse.completed(r));
        Utils.toastMessage(r.message);
        Navigator.pop(navigatorKey.currentContext!);
      },
    );
    notifyListeners();
  }

  Future<void> getOpportunityDetails(int postId) async {
    var data = {"user_id": userId, "post_id": postId};
    setOpportunityResponse(ApiResponse.loading());
    notifyListeners();
    var response = await _myRepo.getOpportunityApi(data);
    response.fold(
      (l) {
        setInterestResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message);
      },
      (r) {
        setOpportunityResponse(ApiResponse.completed(r));
        setOpportunityDetails(r.data!);
        // Utils.toastMessage(r.message!);
      },
    );
    notifyListeners();
  }

  updateMode(int value) {
    radioValue = value;
    notifyListeners();
  }

  setOpportunityDetails(Data data) {
    postNameController = TextEditingController(text: data.name!);
    postExpiryController = TextEditingController(text: data.postExpiryDate!);
    postDescriptionController = TextEditingController(text: data.description!);
    postMinInstaController =
        TextEditingController(text: data.creatorRequired.toString());
    postDeliverablesController = TextEditingController(text: data.deliverable!);
    postAmountController =
        TextEditingController(text: data.perCreatorAmount.toString());
    postDurationController =
        TextEditingController(text: data.duration!.toString());
    updateMode(data.workMode!);
    notifyListeners();
  }
}
