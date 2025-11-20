import 'package:creatoo/core.dart';
import 'package:creatoo/features/opportunity/repository/opportunity_repository.dart';

import '../model/opportunity_response_model.dart';

class OpportunityViewModel with ChangeNotifier {
  final OpportunityRepository _myRepo = OpportunityRepository();
  late TextEditingController reportController;
  bool isLoading = false;
  String searchKey = "all";

  ApiResponse<OpportunityResponse> apiResponse = ApiResponse.initial();

  setResponse(ApiResponse<OpportunityResponse> response) {
    apiResponse = response;
  }

  Future<void> getOpportunities({String filter = "all"}) async {
    reportController = TextEditingController();
    setResponse(ApiResponse.loading());
    notifyListeners();
    var data = {"user_id": userId, "search_key": filter};
    var response = await _myRepo.fetchOpportunitiesApi(data);
    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
      },
      (r) {
        setResponse(ApiResponse.completed(r));
      },
    );
    notifyListeners();
  }

  Future<void> reportPost(int postId) async {
    isLoading = true;
    notifyListeners();
    var data = {
      "user_id": userId,
      "post_id": postId,
      "description": reportController.text.trim(),
    };
    var response = await _myRepo.postReportRequestApi(data);
    response.fold(
      (l) {
        Utils.toastMessage(l.message);
        notifyListeners();
      },
      (r) async {
        Utils.toastMessage(r.message!);
        await getOpportunities(filter: searchKey);
      },
    );
    isLoading = false;
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }
}
